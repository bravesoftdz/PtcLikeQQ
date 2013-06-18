unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, AppEvnts, StdCtrls, ExtCtrls,jpeg, ExtDlgs, Glass;

type
TScreenState = (msDefault,msDrag,msSelected);
  TForm1 = class(TForm)
    ImgScreen: TImage;
    ApplicationEvents1: TApplicationEvents;
    SavePictureDialog1: TSavePictureDialog;
    Glass1: TGlass;
    LblRGB: TLabel;
    LblCancelInfo: TLabel;
    LblActionInfo: TLabel;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure ApplicationEvents1Message(var Msg: tagMSG;
      var Handled: Boolean);
    procedure ImgScreenDblClick(Sender: TObject);
    procedure ImgScreenMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ImgScreenMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ImgScreenMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormShow(Sender: TObject);
    procedure Glass1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
  private
    { Private declarations }

    DX,DY,RectLeft,RectTop,RectBottom,RectRight:Integer;
    MouseIsDown,
    Trace:Boolean;
    ScreenState:TScreenState;
    procedure Cancel;
    procedure SendImg;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormShow(Sender: TObject);
var
  Fullscreen:Tbitmap;
  FullscreenCanvas:TCanvas;
  DC:HDC;
begin
    ScreenState:=msDefault;
    MouseIsDown:=False;
    Trace:=False;
    RectLeft:=-1;
    RectTop:=-1;
    RectBottom:=-1;
    RectRight:=-1;

    Fullscreen := TBitmap.Create;//����һ��BITMAP�����ͼ��
    Fullscreen.Width := Screen.width;
    Fullscreen.Height := Screen.Height;
    DC:=GetDC(0);//ȡ����Ļ��DC������0ָ������Ļ
    FullscreenCanvas := TCanvas.Create;//����һ��CANVAS����
    FullscreenCanvas.Handle := DC;
    Fullscreen.Canvas.CopyRect(Rect(0,0,Screen.Width,Screen.Height),FullscreenCanvas,
    Rect(0,0,Screen.Width,Screen.Height));//��������Ļ���Ƶ�BITMAP��
    FullscreenCanvas.Free;//�ͷ�CANVAS����
    ReleaseDC(0,DC);//�ͷ�DC
    ImgScreen.picture.Bitmap:=fullscreen;//�����µ�ͼ�󸳸�Image1
    ImgScreen.Width := Fullscreen.Width;
    ImgScreen.Height:=Fullscreen.Height;
    Fullscreen.free;//�ͷ�bitmap

    ImgScreen.Canvas.Pen.mode:=pmnot; //�ʵ�ģʽΪȡ��
    ImgScreen.canvas.pen.color:=clblack; //��Ϊ��ɫ
    ImgScreen.canvas.pen.Width:=2;         //�ʿ��
    ImgScreen.canvas.brush.Style:=bsclear; //�հ�ˢ��end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Self.DoubleBuffered:=True;
end;

procedure TForm1.Cancel;
begin
  if ScreenState=msDefault then
    Close 
  else
  begin
    if Trace then ImgScreen.Canvas.Rectangle(RectLeft,RectTop,RectRight,RectBottom);
    Trace:=False;
    ScreenState:=msDefault;
    LblActionInfo.Caption:='��ס����������ѡ���ȡ��Χ';
    LblCancelInfo.Caption:='������Ҽ��˳�';
    exit;
  end;
end;

procedure TForm1.ImgScreenMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  R,G,B:Integer;
begin
  //�ж�ȷ�������pninfo��
  if (X>Glass1.Left) and (X<Glass1.Left+Glass1.Width) and (Y>Glass1.Top) and (Y<Glass1.Top+Glass1.Height) then
  begin
    Glass1MouseMove(Sender,Shift,X,Y);
  end;


  if (ScreenState=msSelected) then
  begin
    ImgScreen.Cursor:=crDefault;
        //�ж�����Ƿ��ڻ����ľ�����
    if (X>RectLeft) and (X<RectRight) and (Y>RectTop) and (Y<RectBottom) then
    begin
      ImgScreen.Cursor:=crSizeAll;
      if MouseIsDown then
      begin
        ImgScreen.Canvas.Rectangle(RectLeft,RectTop,RectRight,RectBottom);
        if (RectLeft+(X-DX)>=1) and (RectRight+(X-DX)<=Screen.Width) then
        begin
          RectLeft:=RectLeft+(X-DX);
          RectRight:=RectRight+(X-DX);
        end;

        if (RectTop+(Y-DY)>=1) and (RectBottom+(Y-DY)<=Screen.Height) then
        begin
          RectTop:=RectTop+(Y-DY);
          RectBottom:=RectBottom+(Y-DY);
        end;
        
        ImgScreen.Canvas.Rectangle(RectLeft,RectTop,RectRight,RectBottom);
        DX:=X;
        DY:=Y;
      end;
    end;
  end
  else
  begin
    ImgScreen.Cursor:=crCross;
  end;

  if (ScreenState=msDrag) and MouseIsDown then
  begin
    if Trace then ImgScreen.Canvas.Rectangle(RectLeft,RectTop,RectRight,RectBottom);
    RectRight:=X;
    RectBottom:=Y;
    ImgScreen.Canvas.Rectangle(RectLeft,RectTop,RectRight,RectBottom);
    Trace:=True;
  end;
  
  R:=getRvalue(ImgScreen.Canvas.Pixels[X, Y]);
  G:=getGvalue(ImgScreen.Canvas.Pixels[X, Y]);
  B:=getBvalue(ImgScreen.Canvas.Pixels[X, Y]);
  LblRGB.Caption:='��ǰ����RGBֵ��'+IntToStr(R)+'��'+IntToStr(G)+'��'+IntToStr(B)+'��';
end;

procedure TForm1.ImgScreenMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button=mbRight then
  begin
    Cancel;
    Exit;
  end;

  if (ScreenState=msSelected) and (ImgScreen.Cursor<>crDefault) then
  begin
    MouseIsDown:=True;
    DX:=X;
    DY:=Y;
  end;

  if ScreenState<>msDefault then exit;
  if Trace then ImgScreen.Canvas.Rectangle(RectLeft,RectTop,RectRight,RectBottom);
  MouseIsDown:=True;
  Trace:=False;
  ScreenState:=msDrag;
  RectLeft:=X;
  RectTop:=Y;
  RectRight:=X;
  RectBottom:=Y;
  LblActionInfo.Caption:='�ɿ���������ȷ�����ս�ȡ��Χ';
  LblCancelInfo.Caption:='������Ҽ�ȡ����ǰѡ��';
end;

procedure TForm1.ImgScreenMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
    MouseIsDown:=False;
    if ScreenState=msDrag then
    begin
      LblActionInfo.Caption:='˫�����ѡ��ǰѡ����ͼ��';
      LblCancelInfo.Caption:='������Ҽ�ȡ����ǰѡ��';
      ScreenState:=msSelected;
    end;
end;

procedure TForm1.SendImg;
var
  newbitmap:TBitmap;
  newjpg:TJPegImage;
  TempInt:Integer;
  ScreenFileName:String;
  Receiver:Integer;
  ReceiverName:String;
begin
  if ScreenState=msSelected then
  begin
    //�жϽ�ͼ�϶���ʽ����ֹͼƬ��ת
    if RectLeft>RectRight then
    begin
      TempInt:=RectLeft;
      RectLeft:=RectRight;
      RectRight:=TempInt;
    end;
    
    if RectTop>RectBottom then
    begin
      TempInt:=RectTop;
      RectTop:=RectBottom;
      RectBottom:=TempInt;
    end;

    //Dec(RectRight);
    //Dec(RectBottom);


    newbitmap:=Tbitmap.create;
    newbitmap.width:=RectRight-RectLeft;
    newbitmap.height:=RectBottom-RectTop;
    if Trace then ImgScreen.Canvas.Rectangle(RectLeft,RectTop,RectRight,RectBottom);
    newbitmap.Canvas.CopyRect(Rect(0, 0, newbitmap.width, newbitmap.height),ImgScreen.canvas,Rect (RectLeft, RectTop,RectRight,RectBottom)); //����
    
    newjpg:=TJPegImage.Create;
    newjpg.Assign(newbitmap);          //ת��ͼƬ��ʽ
    newjpg.CompressionQuality:=90;  //ͼƬѹ������
    newjpg.Compress;                //ͼƬѹ��
    ScreenFileName:=ExtractFilePath(Application.ExeName)+'\Screens\SC'+IntToStr(GetTickCount)+'.JPG';
    if not DirectoryExists(ExtractFilePath(ScreenFileName)) then CreateDir(ExtractFilePath(ScreenFileName)); //Ŀ¼���������½�
    newjpg.SaveToFile(ScreenFileName);         //������ļ�
    newjpg.Free;
    newbitmap.free;

    ScreenState:=msDefault;
    Close;
  end;
end;

procedure TForm1.ApplicationEvents1Message(var Msg: tagMSG;
  var Handled: Boolean);
begin
  if Msg.wParam=27 then     
  begin
    Cancel;
  end;

  if (Msg.wParam=32) or (Msg.wParam=13) then
  begin
    if ScreenState=msSelected then SendImg;
    Handled:=True;
  end;
end;

procedure TForm1.ImgScreenDblClick(Sender: TObject);
begin
    if ScreenState=msSelected then SendImg;
end;

procedure TForm1.Glass1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if Glass1.Left=8 then
    Glass1.Left:=Screen.Width-8-Glass1.Width
  else
    Glass1.Left:=8;
end;

end.
