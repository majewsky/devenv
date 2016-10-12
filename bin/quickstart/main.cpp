#include "view.h"

#include <QtWidgets/QApplication>

int main(int argc, char** argv) {
    QApplication app(argc, argv);

    app.setStyleSheet(QStringLiteral(
        "QPushButton { font-size: 24px }"
    ));

    View view;
    view.setupButtons(QStringList()
        << QStringLiteral("f:firefox")
        << QStringLiteral("o:konsole")
    );
    view.show();

    return app.exec();
}
