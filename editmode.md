# Edit mode

You can specify a line and an E command (or use the current line by just entering E). The count is ignored.

You will see the line printed with no line number. In addition, any tabs will be shown as underscores.
You will then see on the next line, a colon with your cursor one character to the left of the line printed above.

This first character accepts a number of commands:

* ^ - Insert at start of string
* ' - Overwrite at start of string
* \+ - Append to end of string (must be in first character)
* $ - Kill to end of string (make line empty)
* \<space\> - No action

Every other character you input will line up with the characters from the line. You can use most of the same commands:
* ^ - Insert at next character
* ' - Overtype at next character
* $ - Kill from next character to end of string
* x - Delete this character (or X)
* \<space\> - No action


Once you start an action like insert, kill, etc. the rest of the input will apply to that action. This doesn't apply to the X (delete) command but it must come before any other actions. 

## Examples

```
  _org 2000x
:         'h
```

Will change the line to:
```
	org 2000h
```	


```
  _dec rc
:^aloop:
```

Produces:
```
aloop:   dec rc
```

Deletes are special 
```
  db 'This is aa ttest' @
:              x x     '  ; Corrected
```




## End of lines
Lines always end with CRLF. If you overwrite (') a string shorter than a line, the line will fill in the part after the overwrite. If the overwrite is longer, it will extend the length of the line.


