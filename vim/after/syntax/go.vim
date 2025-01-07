syn keyword goType any

if search('onsi/ginkgo', 'nw') > 0
  " all the names of non-deprecated top-level functions in <https://pkg.go.dev/github.com/onsi/ginkgo/v2>
  syn keyword goGinkgoFunction AbortSuite AddReportEntry AfterAll AfterEach AfterSuite AttachProgressReporter BeforeAll BeforeEach BeforeSuite By CurrentSpecReport DeferCleanup Describe DescribeTable DescribeTableSubtree Entry Fail FDescribe FDescribeTable FDescribeTableSubtree FEntry FIt FWhen GinkgoConfiguration GinkgoHelper GinkgoLabelFilter GinkgoParallelProcess GinkgoRandomSeed GinkgoRecover GinkgoT GinkgoTB It JustAfterEach JustBeforeEach Label PauseOutputInterception PDescribe PDescribeTable PDescribeTableSubtree PEntry PIt PreviewSpecs PWhen ReportAfterEach ReportAfterSuite ReportBeforeEach ReportBeforeSuite ResumeOutputInterception RunSpecs Skip SynchronizedAfterSuite SynchronizedBeforeSuite When
  hi link goGinkgoFunction StorageClass
endif

if search('onsi/gomega', 'nw') > 0
  " all the names of non-deprecated top-level functions in <https://pkg.go.dev/github.com/onsi/gomega>, and also To()
  syn keyword goGomegaFunction And BeADirectory BeAnExistingFile BeARegularFile BeAssignableToTypeOf BeClosed BeComparableTo BeElementOf BeEmpty BeEquivalentTo BeFalse BeFalseBecause BeIdenticalTo BeKeyOf BeNil BeNumerically BeSent BeTemporally BeTrue BeTrueBecause BeZero Consistently ConsistentlyWithOffset ConsistOf ContainElement ContainElements ContainSubstring DisableDefaultTimeoutsWhenUsingContext EnforceDefaultTimeoutsWhenUsingContexts Equal Eventually EventuallyWithOffset Expect ExpectWithOffset HaveCap HaveEach HaveExactElements HaveExistingField HaveField HaveHTTPBody HaveHTTPHeaderWithValue HaveHTTPStatus HaveKey HaveKeyWithValue HaveLen HaveOccurred HavePrefix HaveSuffix HaveValue InterceptGomegaFailure InterceptGomegaFailures MatchError MatchJSON MatchRegexp MatchXML MatchYAML NewGomega NewWithT Not Or Panic PanicWith Receive RegisterFailHandler RegisterFailHandlerWithT RegisterTestingT Satisfy SatisfyAll SatisfyAny SetDefaultConsistentlyDuration SetDefaultConsistentlyPollingInterval SetDefaultEventuallyPollingInterval SetDefaultEventuallyTimeout Succeed To WithTransform
  hi link goGomegaFunction Operator
endif
