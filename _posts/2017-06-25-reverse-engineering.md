---
layout: post
title:  "Reverse Engineering для девочек"
date:   2017-06-25 16:42:23 +0700
image: jakyll-blog-logo.jpg
permalink: "reverse-engineering"
categories: [asm,reverse,masm,security,c]
---

## Введение
Название соответствует содержанию, оно краткое и не предполагает глубокое погружение в решаемую задачу. Использован так называемый "инженерный" подход.
### Инструменты:

+ IDA Pro + HexRays (скачать можно на RuTracker)

+ gcc или другой компилятор

+ А больше ничего и не надо

### Цели и задачи этого поста:

+ Написать функциональный аналог программы имея только `.exe` файл

## Разбор

Если вы не хотите использовать декомпиляцию, рекомендую почитать про [ассемблер в Linux для программистов C](https://ru.wikibooks.org/wiki/%D0%90%D1%81%D1%81%D0%B5%D0%BC%D0%B1%D0%BB%D0%B5%D1%80_%D0%B2_Linux_%D0%B4%D0%BB%D1%8F_%D0%BF%D1%80%D0%BE%D0%B3%D1%80%D0%B0%D0%BC%D0%BC%D0%B8%D1%81%D1%82%D0%BE%D0%B2_C), однако, для понимания происходящего в этой статье, вам этого не понадобится.

Установите требуемые инструменты и приступим.

Скачайте [файл]({{ site.baseurl }}/static/download/reverse-engineering/task.ex)(на свой страх и риск, измените `.ex` на `.exe`), он содержит простую программу на `c++` скомпилированную с множеством ключей, для усложнения(?) разбора. 

Откройте консоль в папке с загружееным файлом(shift+ПКМ -> Открыть окно команд) и выполните его.
```
task.exe
#Please, enter 5 unsigned decimal numbers from 0 to 255:
1 1 1 1 1
#Result (decimal):
#166 165 164 163 162
```
Анализируем увиденное:

+ Консольное приложение.

+ Две `string`, попробуем их найти в коде.

Откройте `IDA Pro`, нажмите `New`, найдите и откройте скачанный `task.exe`, в всплывшем окне ничего не меняя нажмите `Ok`. На боковой панели - список функций, на основной - их отображение. Далее кликните(ПКМ) по любой функции в основной панели и выберите `Text view`, перед вами ассемблерный код в синтаксисе `Intel`. Проматайте файл в начало, нажмите в верхней панели на `бинокль T` выполните поиск фрагмента строки. Результат
{% highlight asm %}
push    offset aPleaseEnterUUn ;'Please, enter %u unsigned decimal numbers from 0 to 255:',0Ah,0
{% endhighlight %}
Нажмите `F5`, в случае если вы установили IDA Pro с HexRays перед вами окажется псевдокод(`C`).
{% highlight C %}
int sub_4012E0()
{
  unsigned int v0; // esi@1
  HMODULE v1; // eax@3
  unsigned int v2; // edx@3
  char v3; // bl@3
  unsigned int v4; // esi@5
  char v6; // [sp+4h] [bp-Ch]@1
  int v7; // [sp+5h] [bp-Bh]@1

  v6 = 0;
  v7 = 0;
  sub_401280("Please, enter %u unsigned decimal numbers from 0 to 255:\n", 5);
  v0 = 0;
  do
    sub_4012B0("%hhu", (char)(&v6 + v0++));
  while ( v0 < 5 );
  v1 = GetModuleHandleW(0);
  v2 = 0;
  v3 = *(_BYTE *)v1 + *((_BYTE *)v1 + 1);
  do
  {
    *(&v6 + v2) = v3 ^ (v2 + *(&v6 + v2));
    ++v2;
  }
  while ( v2 < 5 );
  sub_401280("Result (decimal):\n");
  v4 = 0;
  do
    sub_401280("%hhu ", (unsigned __int8)*(&v6 + v4++));
  while ( v4 < 5 );
  sub_401280("\n");
  return 0;
}
{% endhighlight %}

Обратим внимание на сигратуры функций, `sub_4012B0` - это ни что иное как `scanf`, а `sub_401280` - `printf`, очевидно `sub_4012E0` - `main`. Переименуйте(`N`) эти функции. Далее я разберу как выглядит это в asm, а вы можете попробывать сразу написать аналог.

Вызов функции из стандартной библиотеки:
{% highlight C %}
scanf("%hhu", (char)(&v6 + v0++));
{% endhighlight %}

{% highlight asm %}
var_C = byte ptr -0Ch
lea     eax, [ebp+var_C]    ; eax = ebp+var_C адрес массива
add     eax, esi            ; eax = eax+esi адрес esiтого элемента
push    eax                 ; помещение 2 аргумента в стек (int)
push    offset aHhu         ; помещение 1 аргумента в стек  (int)
call	_scanf						/* scanf("%hhu", inputCharArray + i);*/
add     esp, 8              ; возвращение указателя стека 4+4 = 2*(int)
{% endhighlight %}

Цикл выглядит очень просто:
{% highlight C %}
v4 = 0;
do
 <код>
 v4++;
while ( v4 < 5 );
{% endhighlight %}

{% highlight asm %}
xor     esi, esi            ; обнуление счётчика
loc_401310:                 ; метка
<код>
inc     esi                 ; увеличение счётчика
cmp     esi, 5              ; сревнение с 5
jb      short loc_401310    ; переход на метку, если esi<5, jump below
{% endhighlight %}

Создайте файл, напишите аналог, скомпилируйте и убедитесь в совпадении с оригиналом.
```
echo ""> main.cpp
gcc main.cpp main
main.exe
```
Чтобы посмотреть "краткий" код на asm вам поможет ряд команд
```
gcc -s -masm=intel main.cpp ; синтаксис Intel
gcc -s main.cpp             ; синтаксис AT&T
```
## Результат
Как и обещал, привожу функциональный аналог.
{% highlight C %}
#include <iostream>
#include <windows.h>
#define ARRAY_LENGTH 5
int main()
{
  //moduleHandleWOfNULL = 9460301
  const HMODULE moduleHandleWOfNULL = GetModuleHandleW(0);
  const char randomChar =  *(char *)moduleHandleWOfNULL + *((char *)moduleHandleWOfNULL + 1);
  char inputCharArray[ARRAY_LENGTH] = {0};
  printf("Please, enter %u unsigned decimal numbers from 0 to 255:\n", ARRAY_LENGTH);

  for(size_t i = 0;i<ARRAY_LENGTH;i++)
  {
    scanf("%hhu", inputCharArray + i);
    inputCharArray[i] = randomChar ^ (i + inputCharArray[i]);
  }
  printf("Result (decimal):\n");
  for(size_t i = 0;i<ARRAY_LENGTH;i++)
  {
  printf("%hhu ", inputCharArray[i]);
  }
  printf("\n");
  return 0;
}
{% endhighlight %}

В дополнение, привожу код написанный на [masm](https://ru.wikipedia.org/wiki/MASM) для _подобной_ программы и даю вам возможность изучить его самостоятельно. 
{% highlight masm %}
.386
.model flat,stdcall
option casemap: none
include \masm32\include\msvcrt.inc
include /masm32/include/user32.inc
include \masm32\include\kernel32.inc
includelib \masm32\lib\msvcrt.lib
includelib /masm32/lib/user32.lib
includelib \masm32\lib\kernel32.lib
include /masm32/macros/macros.asm 
uselib masm32, comctl32, ws2_32 

ArrayPtrMacro macro ; получение &arr[i]
		mov	eax, [esp+1Ch]
		lea	edx, [esp+13h]
		add	eax, edx
		endm	
.CODE
main PROC
		invoke crt_printf, chr$("Please, enter 5 unsigned decimal numbers from 0 to 255: ")
		mov	dword	ptr [esp+1Ch], 0                ; i
.REPEAT
		ArrayPtrMacro
		invoke crt_scanf, chr$("%hhu"), eax
		ArrayPtrMacro
		movzx	eax, byte ptr [eax]                 ; дополнение нулями(приведение типа)
		mov	ecx, eax
		ArrayPtrMacro
		movzx	eax, byte ptr [eax]                 
		mov	edx, dword	ptr  [esp+1Ch]
		xor	eax, edx ;^
		sub	ecx, eax ;-
		mov	eax, ecx 
		sub	eax, 59h ;-
		mov	ecx, eax
		ArrayPtrMacro
		mov	[eax], cl
		inc dword	ptr  [esp+1Ch]
.UNTIL dword	ptr [esp+1Ch]==5
		invoke crt_printf, chr$("Result (decimal): ")
.REPEAT
		lea	edx, byte ptr [esp+13h]
		mov	eax, dword	ptr [esp+18h]
		add	eax, edx
		movzx	eax, byte ptr [eax]
		movzx	eax, al                             ; cast to uchar
		invoke crt_printf, chr$("%hhu "), eax
		inc dword	ptr [esp+18h]
.UNTIL dword	ptr [esp+18h]==5
	invoke ExitProcess, 0
main ENDP
END main
{% endhighlight %}

Это задание было практикой второго курса по направлению "Компьютерная безопасность" в моём университете.