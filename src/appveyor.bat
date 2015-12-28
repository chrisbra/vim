@echo off
:: Batch file for building/testing Vim on AppVeyor

if /I "%1"=="" (
  set target=build
) else (
  set target=%1
)
goto %target%_%ARCH%
echo Unknown build target.
exit 1


:install_x86
:: ----------------------------------------------------------------------
@echo on
:: Work around for Python 2.7.11
reg copy HKLM\SOFTWARE\Python\PythonCore\2.7 HKLM\SOFTWARE\Python\PythonCore\2.7-32 /s /reg:32
:: Lua
:: Appveyor command doesn't seem to work well when downloading from sf.net.
curl -L "http://downloads.sourceforge.net/project/luabinaries/5.3.2/Windows%%20Libraries/Dynamic/lua-5.3.2_Win32_dllw4_lib.zip" -o lua.zip
7z x lua.zip -oC:\Lua > nul
:: Perl
appveyor DownloadFile http://downloads.activestate.com/ActivePerl/releases/5.22.0.2200/ActivePerl-5.22.0.2200-MSWin32-x86-64int-299195.zip -FileName perl.zip
7z x perl.zip -oC:\ > nul
for /d %%i in (C:\ActivePerl*) do move %%i C:\Perl522
:: Need a patch for Perl > 5.20 and VS <= 2012 
curl -L https://bitbucket.org/k_takata/vim-ktakata-mq/raw/65b664c6eaf4d1e70f81edd87719ade325c0849f/if_perl_vc2012.patch -o perl_vc2012.patch
git apply --check perl_vc2012.patch && git apply perl_vc2012.patch
:: Tcl
appveyor DownloadFile http://downloads.activestate.com/ActiveTcl/releases/8.6.4.1/ActiveTcl8.6.4.1.299124-win32-ix86-threaded.exe -FileName tcl.exe
start /wait tcl.exe --directory C:\Tcl
:: Ruby
:: RubyInstaller is built by MinGW, so we cannot use header files from it.
:: Download the source files and generate config.h for MSVC.
git clone https://github.com/ruby/ruby.git -b ruby_2_2 --depth 1 -q ../ruby
pushd ..\ruby
call win32\configure.bat
nmake .config.h.time
popd
:: Install target for po files
curl -L http://cache.gmane.org//gmane/editors/vim/devel/53942-001.bin -o po_install.patch
git apply --check po_install.patch && git apply po_install.patch

:: Update PATH
path C:\Perl522\perl\bin;%path%;C:\Lua;C:\Tcl\bin;C:\Ruby22\bin
@echo off
goto :eof

:install_x64
:: ----------------------------------------------------------------------
@echo on
:: Work around for Python 2.7.11
reg copy HKLM\SOFTWARE\Python\PythonCore\2.7 HKLM\SOFTWARE\Python\PythonCore\2.7-32 /s /reg:64
:: Lua
:: Appveyor command doesn't seem to work well when downloading from sf.net.
curl -L "http://downloads.sourceforge.net/project/luabinaries/5.3.2/Windows%%20Libraries/Dynamic/lua-5.3.2_Win64_dllw4_lib.zip" -o lua.zip
7z x lua.zip -oC:\Lua > nul
:: Perl
appveyor DownloadFile http://downloads.activestate.com/ActivePerl/releases/5.22.0.2200/ActivePerl-5.22.0.2200-MSWin32-x64-299195.zip -FileName perl.zip
7z x perl.zip -oC:\ > nul
for /d %%i in (C:\ActivePerl*) do move %%i C:\Perl522
:: Need a patch for Perl > 5.20 and VS <= 2012 
curl -L https://bitbucket.org/k_takata/vim-ktakata-mq/raw/65b664c6eaf4d1e70f81edd87719ade325c0849f/if_perl_vc2012.patch -o perl_vc2012.patch
git apply --check perl_vc2012.patch && git apply perl_vc2012.patch
:: Tcl
appveyor DownloadFile http://downloads.activestate.com/ActiveTcl/releases/8.6.4.1/ActiveTcl8.6.4.1.299124-win32-x86_64-threaded.exe -FileName tcl.exe
start /wait tcl.exe --directory C:\Tcl
:: Ruby
:: RubyInstaller is built by MinGW, so we cannot use header files from it.
:: Download the source files and generate config.h for MSVC.
git clone https://github.com/ruby/ruby.git -b ruby_2_2 --depth 1 -q ../ruby
pushd ..\ruby
call win32\configure.bat
nmake .config.h.time
popd
:: Install target for po files
curl -L http://cache.gmane.org//gmane/editors/vim/devel/53942-001.bin -o po_install.patch
git apply --check po_install.patch && git apply po_install.patch

:: Update PATH
path C:\Perl522\perl\bin;%path%;C:\Lua;C:\Tcl\bin;C:\Ruby22-x64\bin
@echo off
goto :eof


:build_x86
:: ----------------------------------------------------------------------
@echo on
:: Remove progress bar from the build log
sed -e "s/\$(LINKARGS2)/\$(LINKARGS2) | sed -e 's#.*\\\\r.*##'/" Make_mvc.mak > Make_mvc2.mak
:: Build GUI version
nmake -f Make_mvc2.mak CPU=i386 ^
	GUI=yes OLE=no DIRECTX=yes ^
	FEATURES=HUGE IME=yes MBYTE=yes ICONV=yes DEBUG=no ^
	PERL_VER=522 DYNAMIC_PERL=yes PERL=C:\Perl522\perl ^
	PYTHON_VER=27 DYNAMIC_PYTHON=yes PYTHON=C:\Python27 ^
	PYTHON3_VER=34 DYNAMIC_PYTHON3=yes PYTHON3=C:\Python34 ^
	LUA_VER=53 DYNAMIC_LUA=yes LUA=C:\Lua ^
	TCL_VER=86 DYNAMIC_TCL=yes TCL=C:\Tcl ^
	RUBY=C:\projects\ruby DYNAMIC_RUBY=yes RUBY_VER=22 RUBY_VER_LONG=2.2.0 ^
	RUBY_INSTALL_NAME=msvcrt-ruby$(RUBY_API_VER) RUBY_PLATFORM=i386-mswin32_100 ^
	RUBY_INC="/I $(RUBY)\include /I $(RUBY)\.ext\include\$(RUBY_PLATFORM)" ^
	WINVER=0x500 ^
	|| exit 1
:: Build CUI version
nmake -f Make_mvc2.mak CPU=i386 ^
	GUI=no OLE=no DIRECTX=no ^
	FEATURES=HUGE IME=yes MBYTE=yes ICONV=yes DEBUG=no ^
	PERL_VER=522 DYNAMIC_PERL=yes PERL=C:\Perl522\perl ^
	PYTHON_VER=27 DYNAMIC_PYTHON=yes PYTHON=C:\Python27 ^
	PYTHON3_VER=34 DYNAMIC_PYTHON3=yes PYTHON3=C:\Python34 ^
	LUA_VER=53 DYNAMIC_LUA=yes LUA=C:\Lua ^
	TCL_VER=86 DYNAMIC_TCL=yes TCL=C:\Tcl ^
	RUBY=C:\projects\ruby DYNAMIC_RUBY=yes RUBY_VER=22 RUBY_VER_LONG=2.2.0 ^
	RUBY_INSTALL_NAME=msvcrt-ruby$(RUBY_API_VER) RUBY_PLATFORM=i386-mswin32_100 ^
	RUBY_INC="/I $(RUBY)\include /I $(RUBY)\.ext\include\$(RUBY_PLATFORM)" ^
	WINVER=0x500 ^
	|| exit 1
:: Build translations
pushd po
nmake -f Make_mvc.mak GETTEXT_PATH=C:\cygwin\bin VIMRUNTIME=..\..\runtime install-all || exit 1
popd

@echo off
goto :eof


:build_x64
:: ----------------------------------------------------------------------
@echo on
:: Remove progress bar from the build log
sed -e "s/\$(LINKARGS2)/\$(LINKARGS2) | sed -e 's#.*\\\\r.*##'/" Make_mvc.mak > Make_mvc2.mak
:: Build GUI version
nmake -f Make_mvc2.mak CPU=AMD64 ^
	GUI=yes OLE=no DIRECTX=yes ^
	FEATURES=HUGE IME=yes MBYTE=yes ICONV=yes DEBUG=no ^
	PERL_VER=522 DYNAMIC_PERL=yes PERL=C:\Perl522\perl ^
	PYTHON_VER=27 DYNAMIC_PYTHON=yes PYTHON=C:\Python27-x64 ^
	PYTHON3_VER=34 DYNAMIC_PYTHON3=yes PYTHON3=C:\Python34-x64 ^
	LUA_VER=53 DYNAMIC_LUA=yes LUA=C:\Lua ^
	TCL_VER=86 DYNAMIC_TCL=yes TCL=C:\Tcl ^
	RUBY=C:\projects\ruby DYNAMIC_RUBY=yes RUBY_VER=22 RUBY_VER_LONG=2.2.0 ^
	RUBY_INSTALL_NAME=msvcrt-ruby$(RUBY_API_VER) RUBY_PLATFORM=x64-mswin64_100 ^
	RUBY_INC="/I $(RUBY)\include /I $(RUBY)\.ext\include\$(RUBY_PLATFORM)" ^
	WINVER=0x500 ^
	|| exit 1
:: Build CUI version
nmake -f Make_mvc2.mak CPU=AMD64 ^
	GUI=no OLE=no DIRECTX=no ^
	FEATURES=HUGE IME=yes MBYTE=yes ICONV=yes DEBUG=no ^
	PERL_VER=522 DYNAMIC_PERL=yes PERL=C:\Perl522\perl ^
	PYTHON_VER=27 DYNAMIC_PYTHON=yes PYTHON=C:\Python27-x64 ^
	PYTHON3_VER=34 DYNAMIC_PYTHON3=yes PYTHON3=C:\Python34-x64 ^
	LUA_VER=53 DYNAMIC_LUA=yes LUA=C:\Lua ^
	TCL_VER=86 DYNAMIC_TCL=yes TCL=C:\Tcl ^
	RUBY=C:\projects\ruby DYNAMIC_RUBY=yes RUBY_VER=22 RUBY_VER_LONG=2.2.0 ^
	RUBY_INSTALL_NAME=msvcrt-ruby$(RUBY_API_VER) RUBY_PLATFORM=x64-mswin64_100 ^
	RUBY_INC="/I $(RUBY)\include /I $(RUBY)\.ext\include\$(RUBY_PLATFORM)" ^
	WINVER=0x500 ^
	|| exit 1
:: Build translations
pushd po
nmake -f Make_mvc.mak GETTEXT_PATH=C:\cygwin\bin VIMRUNTIME=..\..\runtime install-all || exit 1
popd

@echo off
goto :eof
