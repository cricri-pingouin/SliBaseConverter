Unit Unit1;

Interface

Uses
  SysUtils, Classes, Controls, Forms, Dialogs, StdCtrls, ExtCtrls, Clipbrd;

Type
  TForm1 = Class(TForm)
    radgrpFrom: TRadioGroup;
    txtFrom: TEdit;
    radgrpTo: TRadioGroup;
    txtTo: TEdit;
    txtFromBase: TEdit;
    txtToBase: TEdit;
    btnCopy: TButton;
    btnPaste: TButton;
    Procedure txtFromChange(Sender: TObject);
    Procedure radgrpFromClick(Sender: TObject);
    Procedure GoConvert;
    Procedure radgrpToClick(Sender: TObject);
    Procedure btnPasteClick(Sender: TObject);
    Procedure btnCopyClick(Sender: TObject);
  Private
    { Private declarations }
  Public
    { Public declarations }
  End;

Var
  Form1: TForm1;

Implementation

{$R *.dfm}

Function Dec2Roman(Decimal: Int64): String;
Const
  Numbers: Array[1..13] Of Integer = (1, 4, 5, 9, 10, 40, 50, 90, 100, 400, 500, 900, 1000);
  Romans: Array[1..13] Of String = ('I', 'IV', 'V', 'IX', 'X', 'XL', 'L', 'XC', 'C', 'CD', 'D', 'CM', 'M');
Var
  i: Integer;
Begin
  Result := '';
  For i := 13 Downto 1 Do
    While (Decimal >= Numbers[i]) Do
    Begin
      Decimal := Decimal - Numbers[i];
      Result := Result + Romans[i];
    End;
End;

Function Roman2Dec(Roman: String): Int64;
Const
  num = 'IVXLCDM';
  value: Array[1..7] Of integer = (1, 5, 10, 50, 100, 500, 1000);
Var
  i: Integer;
Begin
  result := 0;
  Roman := UpperCase(Roman);
  i := length(Roman);
  While (i >= 1) Do
  Begin
    If i > 1 Then
    Begin
      If pos(Roman[i], num) <= (pos(Roman[i - 1], num)) Then
      Begin
        result := result + value[pos(Roman[i], num)];
        dec(i);
      End
      Else
      Begin
        result := result + value[pos(Roman[i], num)] - value[pos(Roman[i - 1], num)];
        dec(i, 2);
      End;
    End
    Else
    Begin
      result := result + value[pos(Roman[1], num)];
      dec(i);
    End;
  End;
End;

Function MyPower(MyValue: Int64; MyExponent: Integer): Int64;
Var
  i: Integer;
Begin
  If MyExponent = 0 Then
  Begin
    Result := 1;
    exit;
  End;
  Result := MyValue;
  For i := 1 To MyExponent - 1 Do
    Result := Result * MyValue;
End;

Function AnyBaseToDecimal(Value: String; Base: Integer): Int64;
Var
  i, j, ValueLength: Integer;
Const
  Digits = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
Begin
  If (Base < 2) Or (Base > 36) Then
  Begin
    showmessage('Sorry, only bases 2 to 36 are supported!');
    Result := 0;
    Exit;
  End;
  Value := UpperCase(Value);
  ValueLength := Length(Value);
  Result := 0;
  For i := 1 To ValueLength Do
  Begin
    j := Pos(copy(Value, i, 1), Digits);
    If (j > Base) Or (j = 0) Then
    Begin
      showmessage('Character "' + copy(Value, i, 1) + '" is incorrect for base ' + IntToStr(Base));
      Result := 0;
      exit;
    End;
    Result := Result + (j - 1) * MyPower(Base, ValueLength - i);
  End;
End;

Function DecimalToAnyBase(Value: Int64; Base: Integer): String;
Var
  Rest: LongInt;
Const
  Digits = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
Begin
  If (Base < 2) Or (Base > 36) Then
  Begin
    showmessage('Sorry, only bases 2 to 36 are supported!');
    Result := '';
    exit;
  End;
  Result := '';
  While (Value <> 0) Do
  Begin
    Rest := Value Mod Base;
    Value := Value Div Base;
    Result := copy(Digits, Rest + 1, 1) + Result;
  End;
  If Result = '' Then
    Result := '0';
End;

Procedure TForm1.radgrpFromClick(Sender: TObject);
Begin
  GoConvert;
End;

Procedure TForm1.radgrpToClick(Sender: TObject);
Begin
  GoConvert;
End;

Procedure TForm1.txtFromChange(Sender: TObject);
Begin
  GoConvert;
End;

Procedure TForm1.btnCopyClick(Sender: TObject);
Begin
  Clipboard.AsText := txtTo.Text;
End;

Procedure TForm1.btnPasteClick(Sender: TObject);
Begin

  txtFrom.Text := Clipboard.AsText;
End;

Procedure TForm1.GoConvert;
Var
  iValue, iCode: Integer;
Begin
  //No From? Clear To and exit
  If length(PChar(txtFrom.Text)) <= 0 Then
  Begin
    txtTo.Text := '';
    exit;
  End;
  //Same base? Just copy/paste
  If (radgrpFrom.ItemIndex = radgrpTo.ItemIndex) And (radgrpFrom.ItemIndex <> 4) Then
  Begin
    txtTo.Text := txtFrom.Text;
    exit;
  End;
  //From Decimal
  If radgrpFrom.ItemIndex = 0 Then
  Begin
    //Since we will treat txtFrom as integer, make sure it is one first!
    //In other cases we expect a string anyway
    val(txtFrom.Text, iValue, iCode);
    If iCode <> 0 Then
    Begin
      ShowMessage(txtFrom.Text + ' is not a number!');
      exit;
    End;
    //If we reach here, it is an integer, carry on
    Case radgrpTo.ItemIndex Of
      1:
        txtTo.Text := IntToHex(StrToInt64(txtFrom.Text), 1);
      2:
        txtTo.Text := DecimalToAnyBase(StrToInt64(txtFrom.Text), 8);
      3:
        txtTo.Text := DecimalToAnyBase(StrToInt64(txtFrom.Text), 2);
      4:
        txtTo.Text := DecimalToAnyBase(StrToInt64(txtFrom.Text), StrToInt64(txtToBase.Text));
      5:
        txtTo.Text := Dec2Roman(StrToInt64(txtFrom.Text));
    End;
  End
  Else If radgrpFrom.ItemIndex = 1 Then
  Begin
    //From Hexadecimal
    Case radgrpTo.ItemIndex Of
      0:
        txtTo.Text := IntToStr(StrToInt64('$' + txtFrom.Text));
      2:
        txtTo.Text := DecimalToAnyBase(StrToInt64('$' + txtFrom.Text), 8);
      3:
        txtTo.Text := DecimalToAnyBase(StrToInt64('$' + txtFrom.Text), 2);
      4:
        txtTo.Text := DecimalToAnyBase(StrToInt64('$' + txtFrom.Text), StrToInt64(txtToBase.Text));
      5:
        txtTo.Text := Dec2Roman(StrToInt64('$' + txtFrom.Text));
    End;
  End
  Else If radgrpFrom.ItemIndex = 2 Then
  Begin
    //From Octal
    Case radgrpTo.ItemIndex Of
      0:
        txtTo.Text := IntToStr(AnyBaseToDecimal(txtFrom.Text, 8));
      1:
        txtTo.Text := IntToHex(AnyBaseToDecimal(txtFrom.Text, 8), 1);
      3:
        txtTo.Text := DecimalToAnyBase(AnyBaseToDecimal(txtFrom.Text, 8), 2);
      4:
        txtTo.Text := DecimalToAnyBase(AnyBaseToDecimal(txtFrom.Text, 8), StrToInt64(txtToBase.Text));
      5:
        txtTo.Text := Dec2Roman(AnyBaseToDecimal(txtFrom.Text, 8));
    End;
  End
  Else If radgrpFrom.ItemIndex = 3 Then
  Begin
    //From Binary
    Case radgrpTo.ItemIndex Of
      0:
        txtTo.Text := IntToStr(AnyBaseToDecimal(txtFrom.Text, 2));
      1:
        txtTo.Text := IntToHex(AnyBaseToDecimal(txtFrom.Text, 2), 1);
      2:
        txtTo.Text := DecimalToAnyBase(AnyBaseToDecimal(txtFrom.Text, 2), 8);
      4:
        txtTo.Text := DecimalToAnyBase(AnyBaseToDecimal(txtFrom.Text, 2), StrToInt64(txtToBase.Text));
      5:
        txtTo.Text := Dec2Roman(AnyBaseToDecimal(txtFrom.Text, 2));
    End;
  End
  Else If radgrpFrom.ItemIndex = 4 Then
  Begin
    //From user selected base
    Case radgrpTo.ItemIndex Of
      0:
        txtTo.Text := IntToStr(AnyBaseToDecimal(txtFrom.Text, StrToInt64(txtFromBase.Text)));
      1:
        txtTo.Text := IntToHex(AnyBaseToDecimal(txtFrom.Text, StrToInt64(txtFromBase.Text)), 1);
      2:
        txtTo.Text := DecimalToAnyBase(AnyBaseToDecimal(txtFrom.Text, StrToInt64(txtFromBase.Text)), 8);
      3:
        txtTo.Text := DecimalToAnyBase(AnyBaseToDecimal(txtFrom.Text, StrToInt64(txtFromBase.Text)), 2);
      4:
        txtTo.Text := DecimalToAnyBase(AnyBaseToDecimal(txtFrom.Text, StrToInt64(txtFromBase.Text)), StrToInt64(txtToBase.Text));
      5:
        txtTo.Text := Dec2Roman(AnyBaseToDecimal(txtFrom.Text, StrToInt64(txtFromBase.Text)));
    End;
  End
  Else If radgrpFrom.ItemIndex = 5 Then
  Begin
    //From user selected base
    Case radgrpTo.ItemIndex Of
      0:
        txtTo.Text := IntToStr(Roman2Dec(txtFrom.Text));
      1:
        txtTo.Text := IntToHex(Roman2Dec(txtFrom.Text), 1);
      2:
        txtTo.Text := DecimalToAnyBase(Roman2Dec(txtFrom.Text), 8);
      3:
        txtTo.Text := DecimalToAnyBase(Roman2Dec(txtFrom.Text), 2);
      4:
        txtTo.Text := DecimalToAnyBase(Roman2Dec(txtFrom.Text), StrToInt64(txtToBase.Text));
    End;
  End;
End;

End.

