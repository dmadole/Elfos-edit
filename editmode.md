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

Here is a longer transcript showing several types of edits:
```
8>1,8p                                                                       
1:This is a line that will get an initial insert                             
2:This is a line that will get an initial overwrite                          
3:Extend this line please                                                    
4:Insert name here: []                                                       
5:Over name here: [      ]                                                   
6:Delete line here | delete me                                               
7:Fixx the extra things on this line..                                       
8:                                                                           
8>1e                                                                         
  This is a line that will get an initial insert                             
:^Inserted,                                                                  
1:Inserted, This is a line that will get an initial insert                   
1>2e                                                                         
  This is a line that will get an initial overwrite                         
:'Overwrite                                                                 
2:Overwrite line that will get an initial overwrite                         
2>3e                                                                        
  Extend this line please                                                   
:+ Extended as requested                                                    
3:Extend this line please Extended as requested                             
3>4e                                                                        
  Insert name here: []                                                      
:                   ^Al                                                     
4:Insert name here: [Al]                                                    
4>5e                                                                        
  Over name here: [      ]                                                  
:                 'Al                                                       
5:Over name here: [Al    ]                                                  
5>6e                                                                        
  Delete line here | delete me                                              
:                 $                                                         
6:Delete line here                                                          
6>7e                                                                        
  Fixx the extra things on this line..                                      
:    x                              x                                       
7:Fix the extra things on this line. 
7>e                                                                         
  Fix the extra things on this line.                                        
:     xxxx           ^ that appear                                          
7:Fix extra things that appear on this line.
```



## End of lines
Lines always end with CRLF. If you overwrite (') a string shorter than a line, the line will fill in the part after the overwrite. If the overwrite is longer, it will extend the length of the line.


