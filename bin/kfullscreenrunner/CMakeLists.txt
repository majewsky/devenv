project(kfullscreenrunner)

find_package(KDE4 REQUIRED)
include(KDE4Defaults)

add_definitions(${QT_DEFINITIONS} ${KDE4_DEFINITIONS})
include_directories(${KDE4_INCLUDES})
set(kfullscreenrunner_SRCS
	item.cpp
	main.cpp
	view.cpp
)

kde4_add_executable(kfullscreenrunner ${kfullscreenrunner_SRCS})
target_link_libraries(kfullscreenrunner ${KDE4_PLASMA_LIBS})

install(TARGETS kfullscreenrunner ${INSTALL_TARGETS_DEFAULT_ARGS})
