#include <QtCore/QCoreApplication>
#include <QtCore/QDir>
#include <QtCore/QProcess>

#include <cstdio>
#include <cstdlib>
#include <memory>
#include <unistd.h>

QByteArray readFile(const QString& path)
{
	QFile file(path);
	if (file.open(QIODevice::ReadOnly))
		return file.readAll();
	else
		return QByteArray();
}

class RepoReader
{
	protected:
		bool m_isRepo;
		QStringList m_basePathParts, m_pathPartsInRepo;
	public:
		RepoReader(const QStringList& pathParts) : m_isRepo(false), m_basePathParts(pathParts) {}
		virtual ~RepoReader() {}

		bool isRepo() const { return m_isRepo; }
		QByteArray printablePath() const
		{
			if (m_isRepo && !m_pathPartsInRepo.isEmpty())
			{
				const QByteArray basePath = (m_basePathParts.join(QChar('/')) + QChar('/')).toLocal8Bit();
				const QByteArray pathInRepo = m_pathPartsInRepo.join(QChar('/')).toLocal8Bit();
				return "\e[0;36m" + basePath + "\e[1;36m" + pathInRepo + "\e[0m";
			}
			else
			{
				const QByteArray path = (m_basePathParts + m_pathPartsInRepo).join(QChar('/')).toLocal8Bit();
				return "\e[1;36m" + path + "\e[0m";
			}
		}
		virtual QByteArray extraInfo() const
		{
			return QByteArray();
		}
};

class GitRepoReader : public RepoReader
{
	private:
		QByteArray m_branch, m_commit;
	public:
		GitRepoReader(const QStringList& pathParts) : RepoReader(pathParts)
		{
			//NOTE: path is in m_basePathParts at the beginning
			QString gitDirPath;
			while (!m_basePathParts.isEmpty())
			{
				gitDirPath = m_basePathParts.join(QChar('/')) + QLatin1String("/.git");
				//find Git repo for current directory
				if (QDir(gitDirPath).exists())
				{
					m_isRepo = true;
					break;
				}
				//ascend in directory hierarchy as necessary
				m_pathPartsInRepo.prepend(m_basePathParts.takeLast());
			}
			if (m_isRepo)
			{
				//determine current branch and commit
				QByteArray headRef = readFile(gitDirPath + QLatin1String("/HEAD")).simplified();
				if (headRef.startsWith("ref: refs/"))
				{
					const QByteArray refSpec = headRef.mid(5);
					QByteArray headRef2 = headRef.mid(10);
					if (headRef2.startsWith("heads/"))
						//current HEAD is a branch
						m_branch = headRef2.mid(6);
					else
						//current HEAD is a remote or tag (include type specification in branch name)
						m_branch = headRef2;
					//read corresponding file to find commit
					m_commit = readFile(gitDirPath + QChar('/') + refSpec).simplified();
					if (m_commit.isEmpty())
					{
						const QList<QByteArray> packedRefs = readFile(gitDirPath + QLatin1String("/packed-refs")).split('\n');
						foreach (const QByteArray& packedRef, packedRefs)
							if (packedRef.endsWith(refSpec))
							{
								m_commit = packedRef.mid(0, 40);
								break;
							}
					}
				}
				else
				{
					//current HEAD is a commit
					m_branch = QByteArray();
					m_commit = headRef;
				}
			}
		}
		virtual QByteArray extraInfo() const
		{
			if (!m_isRepo)
				return QByteArray();
			QByteArray result;
			//branch
			if (m_branch.isEmpty())
				result += " on \e[1;41mno branch\e[0m";
			else
				result += " on branch " + m_branch;
			//commit
			if (!m_commit.isEmpty())
				result += " at " + m_commit.mid(0, 7);
			//done
			return result;
		}
};

class SvnRepoReader : public RepoReader
{
	private:
		int m_revision;
	public:
		SvnRepoReader(const QStringList& pathParts) : RepoReader(pathParts), m_revision(-1)
		{
			//find highest .svn directory
			//NOTE: path is in m_basePathParts at the beginning
			QString svnDirPath = m_basePathParts.join(QChar('/')) + QLatin1String("/.svn");;
			while (QDir(svnDirPath).exists())
			{
				m_pathPartsInRepo.prepend(m_basePathParts.takeLast());
				svnDirPath = m_basePathParts.join(QChar('/')) + QLatin1String("/.svn");
			}
			m_isRepo = !m_pathPartsInRepo.isEmpty();
			if (m_isRepo)
			{
				//correct a systematic error: the above loop moves one path part too much
				m_basePathParts.append(m_pathPartsInRepo.takeFirst());
				m_isRepo = true;
			}
			//find revision
			QProcess svnInfo;
			svnInfo.setEnvironment(QProcess::systemEnvironment() << "LANG=C");
			svnInfo.start("svn", QStringList() << "info");
			svnInfo.waitForFinished();
			QList<QByteArray> svnInfoLines = svnInfo.readAllStandardOutput().split('\n');
			foreach (const QByteArray& svnInfoLine, svnInfoLines)
				if (svnInfoLine.startsWith("Revision: "))
					m_revision = svnInfoLine.mid(10).toInt();
		}
		virtual QByteArray extraInfo() const
		{
			if (!m_isRepo || m_revision < 0)
				return QByteArray();
			else
				return " at revision " + QByteArray::number(m_revision);
		}
};

static int atoi(const QByteArray& str, int defaultValue)
{
	bool ok;
	const int result = str.toInt(&ok);
	return ok ? result : defaultValue;
}

int main(int argc, char** argv)
{
	QCoreApplication app(argc, argv);
	//get basic information: username, hostname, cwd, shell name
	const int bufferLength = 1024;
	char buffer[bufferLength];
	gethostname(buffer, 1024);
	QByteArray hostname(buffer);
	const QByteArray username(getenv("LOGNAME")), term(getenv("TERM"));
	const QStringList cwdParts = QDir::current().absolutePath().split(QChar('/'));
	const QByteArray shellName(getenv("PRETTYPROMPT_SHELL"));
	int shellLevel = atoi(getenv("SHLVL"), 1);
#if 0
	if (shellName == "zsh")
		shellLevel += 1; //work around a counting problem in zsh
#endif
	shellLevel = qMax(1, shellLevel);
	//determine appearance of username@hostname and prompt symbol
	const char* usernameColor = "0";
	if (username == "root")
		usernameColor = "0;1;41";
	const char* hostnameColor = "0;33";
	if (hostname == "magrathea" || hostname == "magrathea.local")
	{
		hostname = "magrathea";
		hostnameColor = "0;32";
	}
	else if (hostname == "maximegalon")
		hostnameColor = "0;31";
	else if (hostname == "vserver3190")
		hostname = "bethselamin.de";
	//find repos etc.
	RepoReader* repoReader = new GitRepoReader(cwdParts);
	if (!repoReader->isRepo())
	{
		delete repoReader;
		repoReader = new SvnRepoReader(cwdParts);
	}
	//print "username@hostname cwd"
	printf(
		 "\e[%sm%s\e[0m"   //username
		"@\e[%sm%s\e[0m"   //hostname
		"-%s"              //terminal (esp. for identifying screen)
		" %s%s\n"          //cwd, extra info from repo reader
		, usernameColor, username.data()
		, hostnameColor, hostname.data()
		, term.data()
		, repoReader->printablePath().data(), repoReader->extraInfo().data()
	);
	//print shell name and shell level
	printf("%s%i$ ", shellName.data(), shellLevel);
	//cleanup
	delete repoReader;
	return 0;
}
