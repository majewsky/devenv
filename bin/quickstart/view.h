#ifndef QS_VIEW_H
#define QS_VIEW_H

#include <QtWidgets/QWidget>

class View : public QWidget {
    public:
        View();
        void setupButtons(const QStringList& commands);
    protected:
        virtual void focusOutEvent(QFocusEvent* event);
        virtual void keyPressEvent(QKeyEvent* event);
        virtual void paintEvent(QPaintEvent* event);
        virtual void showEvent(QShowEvent* event);
};

#endif // QS_VIEW_H
