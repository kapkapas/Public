program fpcTestAll;

{$mode objfpc}{$H+}

uses
  Interfaces, Forms, GuiTestRunner, lazmouseandkeyinput, tst_AboutEx,
  tst_Actions, tst_Something;

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TGuiTestRunner, TestRunner);
  Application.Run;
end.

