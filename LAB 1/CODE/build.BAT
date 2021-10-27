@echo off
rem ****************************
rem Lab 1 tools using MASM 6.11
rem works with minimum version 4.1.F
rem
rem ****************************
del *.map
del *.hex
del *.obj
del *.lst
del %1.exe
ml %1.asm
