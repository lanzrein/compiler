/*
 * nestedIFS.c
 * 
 * Copyright 2018 johan <johan@LAPTOP-1SRG13AD>
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301, USA.
 * 
 * 
 */


#define IF 321
#define FI 123
#define NO 234

#ifdef IF
int show = 1;
#ifdef FI
int hsow = 1;

#else
	printf("Those lines should be ignored ! \n");
#endif

#endif




#ifdef NOTDEF
int nonexistend = -1;
#ifndef TEST
int hello = 432;
#endif
#else
int existent = 1;
#ifndef TEST
int bye = 234;
#endif
#endif



#ifdef ALPHA
int dummy = 32;
#else
#ifdef IF
#ifdef FI
#ifdef NO
int cow = 42;
#endif
#endif
#endif
#endif


