

#include <Keyboard.h>

bool read_mux(int addresse);
int read_encoder(int num_encoder);
int read_PB_encoder(int num_encoder);
bool read_kbd(int x, int y);
void kbd_cmd(int address);

int encoder = 0;
int readValue;
bool kbd_cooldown = 0;
bool kbd_allLow = 1;
bool ecd_cooldown = 0;
bool ecd_allLow = 1;

void setup()
{
  Serial.begin(9600);
  pinMode(A0, OUTPUT); //s0
  pinMode(A1, OUTPUT); //s1
  pinMode(A2, OUTPUT); //s2
  pinMode(A3, OUTPUT); //s3
  pinMode(9, OUTPUT);  //s3
  digitalWrite(9, HIGH);
  pinMode(16, INPUT); //SIG

  //col
  pinMode(2, OUTPUT);
  pinMode(4, OUTPUT);
  //row
  pinMode(7, INPUT);
  pinMode(8, INPUT);
  pinMode(14, INPUT);
  pinMode(15, INPUT);

  //LEDS
  pinMode(3, OUTPUT);
  pinMode(5, OUTPUT);
  pinMode(6, OUTPUT);
  pinMode(10, OUTPUT);

  digitalWrite(3, HIGH);
  digitalWrite(5, HIGH);
  digitalWrite(6, HIGH);
  digitalWrite(10, HIGH);

  Keyboard.begin();
}

void loop()
{

  //encoder

  for (int i = 0; i < 5; i++)
  {
    readValue = read_encoder(i);
    for (int j = 1; j < 3; j++)
    {
      if (readValue == j)
      {
        kbd_cmd(j + i * 2);
        Serial.println(j + i * 2);
      }
    }
  }

  //encoder pushed

  //check if all encoders are not pressed

  int i = 0;

  while (i < 5 && ecd_allLow == 1)
  {
    if (read_PB_encoder(i) == 0)
    {
      ecd_allLow = 1;
    }
    else
    {
      ecd_allLow = 0;
    }
    i++;
  }

  //remove the cooldown if so
  if (ecd_allLow == 1)
  {
    ecd_cooldown = 0;
  }

  //read PB_encoders
  for (int i = 0; i < 5; i++)
  {
    if (read_PB_encoder(i) == 1 && ecd_cooldown == 0)
    {
      kbd_cmd(i + 11);
      ecd_cooldown = 1;
    }
  }
  ecd_allLow = 1;

  //keyboard

  //check if all keys are not pressed
  int x = 1;
  while (x < 5 && kbd_allLow == 1)
  {
    if (read_kbd(x, 1) == 0 && read_kbd(x, 2) == 0)
    {
      kbd_allLow = 1;
    }
    else
    {
      kbd_allLow = 0;
    }
    x++;
  }

  //remove the cooldown if so
  if (kbd_allLow == 1)
  {
    kbd_cooldown = 0;
  }

  //read keys
  for (int x = 1; x < 5; x++)
  {
    if (read_kbd(x, 1) == 1 && kbd_cooldown == 0)
    {
      kbd_cmd(x + 15);
      kbd_cooldown = 1;
    }
    if (read_kbd(x, 2) == 1 && kbd_cooldown == 0)
    {
      kbd_cmd(x + 19);
      kbd_cooldown = 1;
    }
  }

  kbd_allLow = 1;

  //Serial.println(read_kbd(4,1));
  //read_kbd(1,1);
}

bool read_mux(int addresse)
{
  int A = bitRead(addresse, 0);
  int B = bitRead(addresse, 1);
  int C = bitRead(addresse, 2);
  int D = bitRead(addresse, 3);

  digitalWrite(A0, A);
  digitalWrite(A1, B);
  digitalWrite(A2, C);
  digitalWrite(A3, D);

  return (digitalRead(16));
}
int read_PB_encoder(int num_encoder)
{
  int SW;

  switch (num_encoder)
  {
  case 0:
    SW = 2;
    break;

  case 1:
    SW = 5;
    break;

  case 2:
    SW = 8;
    break;

  case 3:
    SW = 11;
    break;

  case 4:
    SW = 14;
    break;
  }

  if (read_mux(SW) == 0)
  {
    return 1;
  }
  else
  {
    return 0;
  }
}
int read_encoder(int num_encoder)
{
  int CLK;
  int DT;
  switch (num_encoder)
  {
  case 0:
    CLK = 1;
    DT = 0;
    break;

  case 1:
    CLK = 4;
    DT = 3;
    break;

  case 2:
    CLK = 7;
    DT = 6;
    break;

  case 3:
    CLK = 10;
    DT = 9;
    break;

  case 4:
    CLK = 13;
    DT = 12;
    break;
  }

  while (!read_mux(CLK)) //--
  {
    while (!read_mux(DT))
    {
      if (read_mux(CLK))
      {
        return 2;
        break;
      }
    }
  }
  while (!read_mux(DT)) //++
  {
    while (!read_mux(CLK))
    {
      if (read_mux(DT))
      {
        return 1;
        break;
      }
    }
  }
  return 0;
}
bool read_kbd(int x, int y) //x = 7 , 8 , 14 , 15 / y = 2 , 4
{
  int row;
  int col;
  bool state;
  switch (x)
  {
  case 1:
    row = 7;
    break;
  case 2:
    row = 8;
    break;
  case 3:
    row = 14;
    break;
  case 4:
    row = 15;
    break;
  }
  switch (y)
  {
  case 1:
    col = 4;
    break;
  case 2:
    col = 2;
    break;
  }
  //debug
  //Serial.println(col);
  //Serial.println(row);
  digitalWrite(col, HIGH);
  delay(1);
  if (digitalRead(row) == HIGH)
  {
    state = 1;
  }
  else
  {
    state = 0;
  }
  digitalWrite(col, LOW);
  return state;
}
void kbd_cmd(int address)
{
  switch (address)
  {
  case 1:
    Keyboard.press(KEY_F24); //encoder 1 ++
    break;

  case 2:
    Keyboard.press(KEY_F23); //encoder 1 --
    break;

  case 3:
    Keyboard.press(KEY_F24); //encoder 2 ++
    Keyboard.press(KEY_F23);
    break;

  case 4:
    Keyboard.press(KEY_F22); //encoder 2 --
    break;

  case 5:
    Keyboard.press(KEY_F24); //encoder 3 ++
    Keyboard.press(KEY_F22);
    break;

  case 6:
    Keyboard.press(KEY_F23); //encoder 3 --
    Keyboard.press(KEY_F22);
    break;

  case 7:
    Keyboard.press(KEY_F21); //encoder 4 ++
    break;

  case 8:
    Keyboard.press(KEY_F24); //encoder 4 --
    Keyboard.press(KEY_F21);
    break;

  case 9:
    Keyboard.press(KEY_F23); //encoder 5 ++
    Keyboard.press(KEY_F21);
    break;

  case 10:
    Keyboard.press(KEY_F22); //encoder 5 --
    Keyboard.press(KEY_F21);
    break;

  case 11:
    Keyboard.press(KEY_F20); //encoder 1 push
    break;

  case 12:
    Keyboard.press(KEY_F24); //encoder 2 push
    Keyboard.press(KEY_F20);
    break;

  case 13:
    Keyboard.press(KEY_F23); //encoder 3 push
    Keyboard.press(KEY_F20);
    break;

  case 14:
    Keyboard.press(KEY_F22); //encoder 4 push
    Keyboard.press(KEY_F20);
    break;

  case 15:
    Keyboard.press(KEY_F21); //encoder 5 push
    Keyboard.press(KEY_F20);
    break;

  case 16:
    Keyboard.press(KEY_F19); //SW 1;1
    break;

  case 17:
    Keyboard.press(KEY_F24); //SW 2;1
    Keyboard.press(KEY_F19);
    break;

  case 18:
    Keyboard.press(KEY_F23); //SW 3;1
    Keyboard.press(KEY_F19);
    break;

  case 19:
    Keyboard.press(KEY_F22); //SW 4;1
    Keyboard.press(KEY_F19);
    break;

  case 20:
    Keyboard.press(KEY_F21); //SW 1;2
    Keyboard.press(KEY_F19);
    break;

  case 21:
    Keyboard.press(KEY_F20); //SW 2;2
    Keyboard.press(KEY_F19);
    break;

  case 22:
    Keyboard.press(KEY_F18); //SW 3;2
    break;

  case 23:
    Keyboard.press(KEY_F24); //SW 4;2
    Keyboard.press(KEY_F18);
    break;
  }

  Keyboard.releaseAll();
}
