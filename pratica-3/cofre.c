#include <reg51.h>

sfr LCD_Port = 0x90;        /* P1 port as data port */
sbit rs = P1^3;             /* Register select pin */
sbit rw = P1^1;             /* Read/Write pin */
sbit en = P1^2;             /* Enable pin */

//Linhas
sbit R0 = P0^3;
sbit R1 = P0^2;
sbit R2 = P0^1;
sbit R3 = P0^0;

//Colunas 
sbit C0 = P0^6;
sbit C1 = P0^5;
sbit C2 = P0^4;

/* Function to provide delay Approx 1ms with 11.0592 Mhz crystal */
void delay(unsigned int count)
{
    int i, j;
    for(i=0; i<count; i++)
        for(j=0; j<112; j++);
}

/* LCD16x2 command function */
void LCD_Command(char cmnd) 
{
    LCD_Port = (LCD_Port & 0x0F) | (cmnd & 0xF0); /* Send upper nibble */
    rs = 0;                 /* Command reg. */
    rw = 0;                 /* Write operation */
    en = 1;                 /* Enable pulse */
    delay(1);
    en = 0;
    delay(2);
    LCD_Port = (LCD_Port & 0x0F) | (cmnd << 4);   /* Send lower nibble */
    en = 1;                 /* Enable pulse */
    delay(1);
    en = 0;
    delay(5);
}

/* LCD data write function */
void LCD_Char(char char_data) 
{
    LCD_Port = (LCD_Port & 0x0F) | (char_data & 0xF0); /* Send upper nibble */
    rs = 1;                 /* Data reg. */
    rw = 0;                 /* Write operation */
    en = 1;                 /* Enable pulse */
    delay(1);
    en = 0;
    delay(2);
    LCD_Port = (LCD_Port & 0x0F) | (char_data << 4);   /* Send lower nibble */
    en = 1;                 /* Enable pulse */
    delay(1);
    en = 0;
    delay(5);
}

/* Send string to LCD function */
void LCD_String(char *str) 
{
    int i;
    for(i=0; str[i]!=0; i++) /* Send each char of string till the NULL */
    {
        LCD_Char(str[i]);    /* Call LCD data write */
    }
}

/* Send string to LCD function based on X,Y position */
void LCD_String_xy(char row, char pos, char *str) 
{
    if (row == 0)
        LCD_Command((pos & 0x0F) | 0x80);
    else if (row == 1)
        LCD_Command((pos & 0x0F) | 0xC0);
    
    LCD_String(str);         /* Call LCD string function */
}

/* LCD Initialize function */
void LCD_Init(void) 
{
    delay(20);               /* LCD Power ON Initialization time >15ms */
    LCD_Command(0x02);       /* 4bit mode */
    LCD_Command(0x28);       /* Initialization of 16X2 LCD in 4bit mode */
    LCD_Command(0x0C);       /* Display ON Cursor OFF */
    LCD_Command(0x06);       /* Auto Increment cursor */
    LCD_Command(0x01);       /* Clear display */
    LCD_Command(0x80);       /* Cursor at home position */
}

char wait_release(char key) {
    while(C0 == 0 || C1 == 0 || C2 == 0); 
    delay(20); 
    return key;
}

//Varredura do teclado 
char ScanKey() {
    while(1) {
        //Linha 0 
        R0 = 0; 
				R1 = 1; 
				R2 = 1; 
				R3 = 1;
			
        if(C0 == 0) return wait_release('1');
        if(C1 == 0) return wait_release('2');
        if(C2 == 0) return wait_release('3');

        //Linha 1 
        R0 = 1; 
				R1 = 0; 
				R2 = 1; 
				R3 = 1;
			
        if(C0 == 0) return wait_release('4');
        if(C1 == 0) return wait_release('5');
        if(C2 == 0) return wait_release('6');

        //Linha 2 
        R0 = 1; 
				R1 = 1; 
				R2 = 0; 
				R3 = 1;
				
        if(C0 == 0) return wait_release('7');
        if(C1 == 0) return wait_release('8');
        if(C2 == 0) return wait_release('9');

        //Linha 3 
        R0 = 1; 
				R1 = 1; 
				R2 = 1; 
				R3 = 0;
				
        if(C0 == 0) return wait_release('*');
        if(C1 == 0) return wait_release('0');
        if(C2 == 0) return wait_release('#');
    }
}

void main()
{
	char password[5] = "1234"; 
  char input[5];
  int i, match;

  LCD_Init(); 
	LCD_String_xy(0, 0, "Enter PIN:");

  for(i = 0; i < 4; i++) {
		input[i] = ScanKey();
    LCD_Char('*'); 
  }
  input[4] = '\0'; 

  //Verifica a senha 
  match = 1;
  for(i = 0; i < 4; i++) {
		if(input[i] != password[i]) {
			match = 0; 
			break;
    }
  }
		
	LCD_Command(0xC0); //Segunda linha
  if(match == 1) {
		LCD_String_xy(1, 0, "Access Granted ");
  } 
  else {
		LCD_String_xy(1, 0, "Access Denied  ");
  }
}