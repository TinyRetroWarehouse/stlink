# FindLibUSB.cmake
# Once done this will define
#
#  LIBUSB_FOUND - System has libusb
#  LIBUSB_INCLUDE_DIR - The libusb include directory
#  LIBUSB_LIBRARY - The libraries needed to use libusb
#  LIBUSB_DEFINITIONS - Compiler switches required for using libusb


if (CMAKE_SYSTEM_NAME STREQUAL "FreeBSD")      # FreeBSD
    FIND_PATH(LIBUSB_INCLUDE_DIR NAMES libusb.h
  	HINTS
	  /usr/include
	  )
else ()                                        # other OS
	  FIND_PATH(LIBUSB_INCLUDE_DIR NAMES libusb.h
	  HINTS
	  /usr
	  /usr/local
	  /opt
	  PATH_SUFFIXES libusb-1.0
	  )
endif()


# macOS
if (APPLE)
	  set(LIBUSB_NAME libusb-1.0.a)
elseif(MSYS OR MINGW)
	  set(LIBUSB_NAME usb-1.0)
elseif(MSVC)
	  set(LIBUSB_NAME libusb-1.0.lib)
elseif(CMAKE_SYSTEM_NAME STREQUAL "FreeBSD")
	  set(LIBUSB_NAME usb)
else()
	  set(LIBUSB_NAME usb-1.0)
endif()

if (MSYS OR MINGW)
	  if (CMAKE_SIZEOF_VOID_P EQUAL 8)
	  	  find_library(
				    LIBUSB_LIBRARY NAMES ${LIBUSB_NAME}
		        HINTS ${LIBUSB_WIN_OUTPUT_FOLDER}/MinGW64/static)
	  else ()
		    find_library(
				    LIBUSB_LIBRARY NAMES ${LIBUSB_NAME}
			      HINTS ${LIBUSB_WIN_OUTPUT_FOLDER}/MinGW32/static)
	  endif ()
elseif (MSVC)
	  if (CMAKE_SIZEOF_VOID_P EQUAL 8)
	    	find_library(
				    LIBUSB_LIBRARY NAMES ${LIBUSB_NAME}
            HINTS ${LIBUSB_WIN_OUTPUT_FOLDER}/MS64/dll)
	  else ()
		    find_library(
				    LIBUSB_LIBRARY NAMES ${LIBUSB_NAME}
			      HINTS ${LIBUSB_WIN_OUTPUT_FOLDER}/MS32/dll)
	  endif ()
else()
  	find_library(LIBUSB_LIBRARY NAMES ${LIBUSB_NAME}
  	HINTS
  	/usr
	  /usr/local
	  /opt)
endif ()

include(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(Libusb DEFAULT_MSG LIBUSB_LIBRARY LIBUSB_INCLUDE_DIR)

mark_as_advanced(LIBUSB_INCLUDE_DIR LIBUSB_LIBRARY)

if(NOT LIBUSB_FOUND)
    if(WIN32 OR MSVC OR MINGW OR MSYS)
        find_package(7Zip REQUIRED)

        set(LIBUSB_WIN_VERSION 1.0.23)
        set(LIBUSB_WIN_ARCHIVE libusb-${LIBUSB_WIN_VERSION}.7z)
        set(LIBUSB_WIN_ARCHIVE_PATH ${CMAKE_BINARY_DIR}/${LIBUSB_WIN_ARCHIVE})
        set(LIBUSB_WIN_OUTPUT_FOLDER ${CMAKE_BINARY_DIR}/3rdparty/libusb-${LIBUSB_WIN_VERSION})

        if(EXISTS ${LIBUSB_WIN_ARCHIVE_PATH})
            message(STATUS "libusb archive already in build folder")
        else()
            message(STATUS "downloading libusb ${LIBUSB_WIN_VERSION}")
            file(DOWNLOAD
                https://sourceforge.net/projects/libusb/files/libusb-1.0/libusb-${LIBUSB_WIN_VERSION}/libusb-${LIBUSB_WIN_VERSION}.7z/download
                ${LIBUSB_WIN_ARCHIVE_PATH}
                EXPECTED_MD5 cf3d38d2ff053ef343d10c0b8b0950c2
            )
        endif()
        file(MAKE_DIRECTORY ${LIBUSB_WIN_OUTPUT_FOLDER})

        if(${ZIP_EXECUTABLE} MATCHES "p7zip")
            #execute_process(COMMAND ${ZIP_EXECUTABLE} -d --keep -f ${LIBUSB_WIN_ARCHIVE_PATH} WORKING_DIRECTORY ${LIBUSB_WIN_OUTPUT_FOLDER})
            execute_process(COMMAND ${ZIP_EXECUTABLE} -d ${LIBUSB_WIN_ARCHIVE_PATH} WORKING_DIRECTORY ${LIBUSB_WIN_OUTPUT_FOLDER})
        else()
            execute_process(COMMAND ${ZIP_EXECUTABLE} x -y ${LIBUSB_WIN_ARCHIVE_PATH} -o${LIBUSB_WIN_OUTPUT_FOLDER})
        endif()

        FIND_PATH(LIBUSB_INCLUDE_DIR NAMES libusb.h
        HINTS ${LIBUSB_WIN_OUTPUT_FOLDER}/include
        PATH_SUFFIXES libusb-1.0
        NO_DEFAULT_PATH
        NO_CMAKE_FIND_ROOT_PATH
        )

        if (MSYS OR MINGW)
            if (CMAKE_SIZEOF_VOID_P EQUAL 8)
                find_library(
								    LIBUSB_LIBRARY NAMES ${LIBUSB_NAME}
                    HINTS ${LIBUSB_WIN_OUTPUT_FOLDER}/MinGW64/static
                    NO_DEFAULT_PATH
                    NO_CMAKE_FIND_ROOT_PATH
                    )
            else ()
                find_library(
								    LIBUSB_LIBRARY NAMES ${LIBUSB_NAME}
                    HINTS ${LIBUSB_WIN_OUTPUT_FOLDER}/MinGW32/static
                    NO_DEFAULT_PATH
                    NO_CMAKE_FIND_ROOT_PATH
                    )
            endif ()
        elseif(MSVC)
            if (CMAKE_SIZEOF_VOID_P EQUAL 8)
                find_library(
								    LIBUSB_LIBRARY NAMES ${LIBUSB_NAME}
                    HINTS ${LIBUSB_WIN_OUTPUT_FOLDER}/MS64/dll
                    NO_DEFAULT_PATH
                    NO_CMAKE_FIND_ROOT_PATH
                    )
            else ()
                find_library(
								    LIBUSB_LIBRARY NAMES ${LIBUSB_NAME}
                    HINTS ${LIBUSB_WIN_OUTPUT_FOLDER}/MS32/dll
                    NO_DEFAULT_PATH
                    NO_CMAKE_FIND_ROOT_PATH
                    )
            endif ()
        endif ()
        FIND_PACKAGE_HANDLE_STANDARD_ARGS(Libusb DEFAULT_MSG LIBUSB_LIBRARY LIBUSB_INCLUDE_DIR)
    endif()
else()
    message(STATUS "found USB")
endif()
