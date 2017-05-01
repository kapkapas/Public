unit frm_EditName;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Grids,
  StdCtrls, Menus, frm_EditCitations, FMUtils, LCLType, Spin, Buttons,
  ExtCtrls, ComboEx;

type
  enumNameEditType = (
    eNET_EditExisting,
    eNET_NewUnrelated,
    eNET_AddFather,
    eNET_AddMother,
    eNET_AddSpouse,
    eNET_AddBrother,
    eNET_AddSister,
    eNET_AddSon,
    eNET_AddDaughter);
  { TfrmEditName }

  TfrmEditName = class(TForm)
    Ajouter1: TMenuItem;
    btnOK: TBitBtn;
    btnCancel: TBitBtn;
    cbxSex: TComboBoxEx;
    edtName: TEdit;
    I: TSpinEdit;
    imglSex: TImageList;
    lblType: TLabel;
    lblForSorting: TLabel;
    lblIndividuum: TLabel;
    lblMemo: TLabel;
    lblPhrase: TLabel;
    lblDate: TLabel;
    lblDefault: TLabel;
    lblSources: TLabel;
    lblName8: TLabel;
    lblForPresentation: TLabel;
    M: TMemo;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem15: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    Modifier1: TMenuItem;
    No: TSpinEdit;
    pnlBottom: TPanel;
    X: TEdit;
    P: TMemo;
    P2: TMemo;
    P1: TMemo;
    PD: TEdit;
    PopupMenu2: TPopupMenu;
    PopupMenuNom: TPopupMenu;
    SD: TEdit;
    PD2: TEdit;
    SD2: TEdit;
    Supprimer1: TMenuItem;
    TableauCitations: TStringGrid;
    TableauNoms: TStringGrid;
    Ajout: TEdit;
    Y: TComboBox;
    procedure Ajouter1Click(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure edtNameExit(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure IEditingDone(Sender: TObject);
    procedure MEditingDone(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
    procedure MenuItem6Click(Sender: TObject);
    procedure P2DblClick(Sender: TObject);
    procedure PDblClick(Sender: TObject);
    procedure PDEditingDone(Sender: TObject);
    procedure PEditingDone(Sender: TObject);
    procedure SDEditingDone(Sender: TObject);
    procedure Supprimer1Click(Sender: TObject);
    procedure TableauCitationsDblClick(Sender: TObject);
    procedure YChange(Sender: TObject);
  private
    FEditType: enumNameEditType;
    FRelID: integer;
    function GetIdName: integer;
    procedure SetEditType(AValue: enumNameEditType);
    procedure SetIdName(AValue: integer);
    procedure SetRelID(AValue: integer);
    { private declarations }
  public
    { public declarations }
    property EditType: enumNameEditType read FEditType write SetEditType;
    property RelID: integer read FRelID write SetRelID;
    property idName:integer read GetIdName write SetIdName;
  end;

procedure NomSaveData;

var
  frmEditName: TfrmEditName;

implementation

uses
  frm_Names, frm_Main, Traduction, dm_GenData, frm_Explorer;

procedure FillNameTable( const suffixe: string; const nom: string;
  const prenom: string; const titre: string);
var j: integer;
begin
  with frmEditName do
   try
  TableauNoms.RowCount :=5;
  j := 1;
      if length(titre) > 0 then
      begin
        TableauNoms.Cells[1, j] := STitle;
        TableauNoms.Cells[2, j] := titre;
        j := j + 1;
      end;
      if length(prenom) > 0 then
      begin
        TableauNoms.Cells[1, j] := SGivenName;
        TableauNoms.Cells[2, j] := prenom;
        j := j + 1;
      end;
      if length(nom) > 0 then
      begin
        TableauNoms.Cells[1, j] := SFamilyName;
        TableauNoms.Cells[2, j] := nom;
        j := j + 1;
      end;
      if length(suffixe) > 0 then
      begin
        TableauNoms.Cells[1, j] := SSuffix;
        TableauNoms.Cells[2, j] := Suffixe;
        j := j + 1;
      end;
      TableauNoms.RowCount := j;

   except
   end;

end;

procedure DecodeFullName(sFullName: string;
  out sSuffix, sFamilyName, sGivenName, sTitle: string);
var Pos2: integer; Pos1: integer;
begin
  sSuffix := '';
    sFamilyName := '';
    sGivenName := '';
    sTitle := '';
    if copy(sFullName, 1, 5) = '!TMG|' then
    begin
      sFullName := copy(sFullName, 6, length(sFullName));
      sFamilyName := trim(copy(sFullName, 1, AnsiPos('|', sFullName) - 1));
      sFullName := copy(sFullName, AnsiPos('|', sFullName) + 1, length(sFullName));
      sTitle := trim(copy(sFullName, 1, AnsiPos('|', sFullName) - 1));
      sFullName := copy(sFullName, AnsiPos('|', sFullName) + 1, length(sFullName));
      sGivenName := trim(copy(sFullName, 1, AnsiPos('|', sFullName) - 1));
      sFullName := copy(sFullName, AnsiPos('|', sFullName) + 1, length(sFullName));
      sSuffix := trim(copy(sFullName, 1, AnsiPos('|', sFullName) - 1));
    end
    else
    begin
      // Traiter les noms avec <N=sTitle></N>...
      Pos1 := AnsiPos('<' + CTagNameTitle + '>', sFullName) + length(CTagNameTitle) + 2;
      Pos2 := AnsiPos('</' + CTagNameTitle + '>', sFullName);
      if (Pos1 + Pos2) > length(CTagNameTitle) + 2 then
        sTitle := Copy(sFullName, Pos1, Pos2 - Pos1);
      Pos1 := AnsiPos('<' + CTagNameGivenName + '>', sFullName) +
        length(CTagNameGivenName) + 2;
      // 9 car le 'é' prends 2 position en ANSI
      Pos2 := AnsiPos('</' + CTagNameGivenName + '>', sFullName);
      if (Pos1 + Pos2) > length(CTagNameGivenName) + 2 then
        sGivenName := Copy(sFullName, Pos1, Pos2 - Pos1);
      Pos1 := AnsiPos('<' + CTagNameFamilyName + '>', sFullName) +
        length(CTagNameFamilyName) + 2;
      Pos2 := AnsiPos('</' + CTagNameFamilyName + '>', sFullName);
      if (Pos1 + Pos2) > length(CTagNameFamilyName) + 2 then
        sFamilyName := Copy(sFullName, Pos1, Pos2 - Pos1);
      Pos1 := AnsiPos('<' + CTagNameSuffix + '>', sFullName) + length(CTagNameSuffix) + 2;
      Pos2 := AnsiPos('</' + CTagNameSuffix + '>', sFullName);
      if (Pos1 + Pos2) > length(CTagNameSuffix) + 2 then
        sSuffix := Copy(sFullName, Pos1, Pos2 - Pos1);
    end;
end;

{$R *.lfm}

{ TfrmEditName }

procedure TfrmEditName.TableauCitationsDblClick(Sender: TObject);
begin
  if TableauCitations.Row > 0 then
  begin
    dmGenData.PutCode('N', StrToInt(TableauCitations.Cells[0, TableauCitations.Row]));
    if EditCitations.Showmodal = mrOk then
      dmGenData.PopulateCitations(TableauCitations, 'N', No.Value);
  end;
end;

procedure TfrmEditName.YChange(Sender: TObject);
begin
  P1.Text :=dmGenData.GetTypePhrase(PtrInt(Y.Items.Objects[Y.ItemIndex]));
  if lblDefault.Visible then
  begin
    P.Text := dmGenData.Query1.Fields[0].AsString;
    P2.Text := DecodePhrase(frmStemmaMainForm.iID, 'PRINCIPAL', P.Text, 'N', No.Value);
  end
  else
    lblDefault.Visible := (P.Text = P1.Text);
end;

procedure TfrmEditName.SetEditType(AValue: enumNameEditType);
begin
  if FEditType = AValue then
    Exit;
  FEditType := AValue;
end;

function TfrmEditName.GetIdName: integer;
begin
  result := no.Value;
end;

procedure TfrmEditName.SetIdName(AValue: integer);
begin
  if no.Value=AValue then exit;
  no.Value:=AValue;
end;

procedure TfrmEditName.SetRelID(AValue: integer);
begin
  if FRelID = AValue then
    Exit;
  FRelID := AValue;
end;

procedure TfrmEditName.P2DblClick(Sender: TObject);
begin
  P.Visible := True;
  P2.Visible := False;
end;

procedure TfrmEditName.FormShow(Sender: TObject);
var
  titre, prenom, nom, suffixe, temp: string;
  j, Pos1, Pos2: integer;
begin
  frmEditName.ActiveControl := frmEditName.TableauNoms;
  frmStemmaMainForm.DataHist.Row := 0;
  Caption := Traduction.Items[182];
//  btnOK.Caption := Traduction.Items[152];
//  btnCancel.Caption := Traduction.Items[164];
  lblType.Caption := Traduction.Items[166];
  lblIndividuum.Caption := Traduction.Items[183];
  lblMemo.Caption := Traduction.Items[171];
  lblPhrase.Caption := Traduction.Items[172];
  lblDate.Caption := Traduction.Items[144];
  lblDefault.Caption := Traduction.Items[173];
  lblSources.Caption := Traduction.Items[174];
  lblName8.Caption := Traduction.Items[184];
  lblForPresentation.Caption := Traduction.Items[168];
  lblForSorting.Caption := Traduction.Items[169];
  TableauNoms.RowCount:=1;
 // TableauNoms.ColCount:=3;
  TableauNoms.Columns[0].Title.Caption := Traduction.Items[185];
  TableauNoms.Columns[1].title.Caption := Traduction.Items[155];
  TableauCitations.RowCount:=1;
  TableauCitations.Columns[0].Title.Caption := Traduction.Items[138];
  TableauCitations.Columns[1].Title.Caption := Traduction.Items[155];
  TableauCitations.Columns[2].Title.Caption := Traduction.Items[177];
  MenuItem1.Caption := Traduction.Items[229];
  MenuItem2.Caption := Traduction.Items[230];
  MenuItem3.Caption := Traduction.Items[231];
  MenuItem4.Caption := Traduction.Items[232];
  MenuItem9.Caption := Traduction.Items[228];
  MenuItem10.Caption := Traduction.Items[224];
  MenuItem11.Caption := Traduction.Items[225];
  MenuItem12.Caption := Traduction.Items[226];
  Ajouter1.Caption := Traduction.Items[224];
  Modifier1.Caption := Traduction.Items[225];
  Supprimer1.Caption := Traduction.Items[226];
  // Populate le ComboBox
  dmGenData.GetTypeList(Y.Items,'N');
  TableauNoms.RowCount := 5;
  // Populate la form
  Ajout.Text := '0';
  case FEditType of
    eNET_AddSpouse: //New unrelated
    begin
      TableauNoms.RowCount := 1;
      frmEditName.Caption :=
        Traduction.Items[318] + dmGenData.GetIndividuumName(
        frmStemmaMainForm.iID);
      if dmGenData.GetSexOfInd(frmStemmaMainForm.iID) ='M' then
        cbxSex.ItemIndex:=2
      else
        cbxSex.ItemIndex:=1;
      Ajout.Text := '1';
    end;
    eNET_AddSon:  // fils
      // Ajouter NOM s'il y a lieu
    begin
      Ajout.Text := '1';
      cbxSex.ItemIndex:=1;
      dmGenData.Query1.SQL.Text:='SELECT S FROM I WHERE no=' + frmStemmaMainForm.sID;
      dmGenData.Query1.Open;
      if dmGenData.Query1.Fields[0].AsString = 'M' then
      begin
        dmGenData.Query1.SQL.Text:='SELECT N FROM N WHERE X=1 AND I=' +
          frmStemmaMainForm.sID;
        dmGenData.Query1.Open;
        temp := dmGenData.Query1.Fields[0].AsString;
        nom := '';
        if copy(temp, 1, 5) = '!TMG|' then
        begin
          temp := copy(temp, 6, length(temp));
          nom := trim(copy(temp, 1, AnsiPos('|', temp) - 1));
        end
        else
        begin
          // Traiter les noms avec <N=TITRE></N>...
          Pos1 := AnsiPos('<' + CTagNameFamilyName + '>', temp) + 5;
          Pos2 := AnsiPos('</' + CTagNameFamilyName + '>', temp);
          if (Pos1 + Pos2) > 5 then
            nom := Copy(temp, Pos1, Pos2 - Pos1);
        end;
        if length(nom) > 0 then
        begin
          TableauNoms.RowCount := 2;
          TableauNoms.Cells[1, 1] := SFamilyName;
          TableauNoms.Cells[2, 1] := nom;
        end
        else
          TableauNoms.RowCount := 1;
      end
      else
        TableauNoms.RowCount := 1;
      frmEditName.Caption :=
        Traduction.Items[315] + dmGenData.GetIndividuumName(
        frmStemmaMainForm.iID);
    end;
    eNET_AddDaughter: // fr: fille
      // en: daughter
      // Ajouter NOM s'il y a lieu }
    begin
      Ajout.Text := '1';
       cbxSex.ItemIndex:=2;
      dmGenData.Query1.SQL.Text:='SELECT S FROM I WHERE no=' + frmStemmaMainForm.sID;
      dmGenData.Query1.Open;
      if dmGenData.Query1.Fields[0].AsString = 'M' then
      begin
        dmGenData.Query1.SQL.Text:='SELECT N FROM N WHERE X=1 AND I=' +
          frmStemmaMainForm.sID;
        dmGenData.Query1.Open;
        temp := dmGenData.Query1.Fields[0].AsString;
        nom := '';
        if copy(temp, 1, 5) = '!TMG|' then
        begin
          temp := copy(temp, 6, length(temp));
          nom := trim(copy(temp, 1, AnsiPos('|', temp) - 1));
        end
        else
        begin
          // Traiter les noms avec <N=TITRE></N>...
          Pos1 := AnsiPos('<' + CTagNameFamilyName + '>', temp) +
            length(CTagNameFamilyName) + 2;
          Pos2 := AnsiPos('</' + CTagNameFamilyName + '>', temp);
          if (Pos1 + Pos2) > length(CTagNameFamilyName) + 2 then
            nom := Copy(temp, Pos1, Pos2 - Pos1);
        end;
        if length(nom) > 0 then
        begin
          TableauNoms.RowCount := 2;
          TableauNoms.Cells[1, 1] := SFamilyName;
          TableauNoms.Cells[2, 1] := nom;
        end
        else
          TableauNoms.RowCount := 1;
      end
      else
        TableauNoms.RowCount := 1;
      frmEditName.Caption :=
        Traduction.Items[316] + dmGenData.GetIndividuumName(
        frmStemmaMainForm.iID);
    end;
    eNET_AddBrother:  // fr: frère
      // en: Brother
      // Ajouter NOM }
    begin
       cbxSex.ItemIndex:=1;
      dmGenData.Query1.SQL.Text:='SELECT N FROM N WHERE X=1 AND I=' +
        frmStemmaMainForm.sID;
      dmGenData.Query1.Open;
      temp := dmGenData.Query1.Fields[0].AsString;
      nom := '';
      if copy(temp, 1, 5) = '!TMG|' then
      begin
        temp := copy(temp, 6, length(temp));
        nom := trim(copy(temp, 1, AnsiPos('|', temp) - 1));
      end
      else
      begin
        // Traiter les noms avec <N=TITRE></N>...
        Pos1 := AnsiPos('<' + CTagNameFamilyName + '>', temp) +
          length(CTagNameFamilyName) + 2;
        Pos2 := AnsiPos('</' + CTagNameFamilyName + '>', temp);
        if (Pos1 + Pos2) > length(CTagNameFamilyName) + 2 then
          nom := Copy(temp, Pos1, Pos2 - Pos1);
      end;
      if length(nom) > 0 then
      begin
        TableauNoms.RowCount := 2;
        TableauNoms.Cells[1, 1] := SFamilyName;
        TableauNoms.Cells[2, 1] := nom;
      end
      else
        TableauNoms.RowCount := 1;
      frmEditName.Caption :=
        Traduction.Items[313] + dmGenData.GetIndividuumName(
        frmStemmaMainForm.iID);
    end;
    eNET_AddSister: // soeur
      // Ajouter NOM }
    begin
       cbxSex.ItemIndex:=2;
      dmGenData.Query1.SQL.Text:='SELECT N FROM N WHERE X=1 AND I=' +
        frmStemmaMainForm.sID;
      dmGenData.Query1.Open;
      temp := dmGenData.Query1.Fields[0].AsString;
      nom := '';
      if copy(temp, 1, 5) = '!TMG|' then
      begin
        temp := copy(temp, 6, length(temp));
        nom := trim(copy(temp, 1, AnsiPos('|', temp) - 1));
      end
      else
      begin
        // Traiter les noms avec <N=TITRE></N>...
        Pos1 := AnsiPos('<' + CTagNameFamilyName + '>', temp) +
          length(CTagNameFamilyName) + 2;
        Pos2 := AnsiPos('</' + CTagNameFamilyName + '>', temp);
        if (Pos1 + Pos2) > length(CTagNameFamilyName) + 2 then
          nom := Copy(temp, Pos1, Pos2 - Pos1);
      end;
      if length(nom) > 0 then
      begin
        TableauNoms.RowCount := 2;
        TableauNoms.Cells[1, 1] := SFamilyName;
        TableauNoms.Cells[2, 1] := nom;
      end
      else
        TableauNoms.RowCount := 1;
      frmEditName.Caption :=
        Traduction.Items[337] + dmGenData.GetIndividuumName(
        frmStemmaMainForm.iID);
    end;
    eNET_AddFather:  // fr: Père
      // en: Father
      // Ajouter NOM }
    begin
       cbxSex.ItemIndex:=1;
      temp := dmGenData.GetIndividuumName(frmStemmaMainForm.iID);
      nom := '';
      if copy(temp, 1, 5) = '!TMG|' then
      begin
        temp := copy(temp, 6, length(temp));
        nom := trim(copy(temp, 1, AnsiPos('|', temp) - 1));
      end
      else
      begin
        // Traiter les noms avec <N=TITRE></N>...
        Pos1 := AnsiPos('<' + CTagNameFamilyName + '>', temp) +
          length(CTagNameFamilyName) + 2;
        Pos2 := AnsiPos('</' + CTagNameFamilyName + '>', temp);
        if (Pos1 + Pos2) > length(CTagNameFamilyName) + 2 then
          nom := Copy(temp, Pos1, Pos2 - Pos1);
      end;
      if length(nom) > 0 then
      begin
        TableauNoms.RowCount := 2;
        TableauNoms.Cells[1, 1] := SFamilyName;
        TableauNoms.Cells[2, 1] := nom;
      end
      else
        TableauNoms.RowCount := 1;
      frmEditName.Caption :=
        Traduction.Items[311] + dmGenData.GetIndividuumName(
        frmStemmaMainForm.iID);
    end;
    eNET_AddMother:  // Mère
    begin
       cbxSex.ItemIndex:=2;
      frmEditName.Caption :=
        Traduction.Items[312] + dmGenData.GetIndividuumName(
        frmStemmaMainForm.iID);
      TableauNoms.RowCount := 1;
    end;
    eNET_NewUnrelated:  // Non-Relié
    begin
       cbxSex.ItemIndex:=0;
      frmEditName.Caption := Traduction.Items[35];
      TableauNoms.RowCount := 1;
    end;
      //        if length(frmEditName.Caption)=0 then
      //           begin
      //           frmEditName.Caption:=Traduction.Items[35];
      //           TableauNoms.RowCount:=1;
      //        end;
    else
    begin
      TableauNoms.RowCount := 1;
      frmEditName.Caption := Traduction.Items[36];
      I.Value := frmStemmaMainForm.iID;
      X.Text := '0';
    end;

  end;
  I.ReadOnly := True;
  I.Value := 0;
  X.Text := '1';
  btnOK.Enabled := True;
  if FEditType <> eNET_EditExisting then
  begin

    TableauCitations.RowCount := 1;
    No.Value := 0;
    M.Text := '';
    P.Text := '';
    P1.Text := '';
    P2.Text := '';
    PD.Text := '';
    edtName.Caption:='';
    PD2.Text := InterpreteDate('', 1);
    ;
    SD.Text := '';
    SD2.Text := PD2.Text;
    Y.ItemIndex := 0;
    lblDefault.Visible := True;
  end
  else
  begin
    dmGenData.Query1.close;
    dmGenData.Query1.SQL.text:='SELECT N.no, N.I, N.Y, N.N, N.M, N.P, N.PD, N.SD, N.X FROM  N WHERE N.no=:idName';
    dmgenData.query1.ParamByName('idName').AsInteger := no.Value;
    dmGenData.Query1.Open;
    dmGenData.Query1.First;
    temp := dmGenData.Query1.Fields[3].AsString;
    DecodeFullName(temp, suffixe, nom, prenom, titre);
    edtName.Caption:=DecodeName(temp,1);
    FillNameTable(suffixe, nom, prenom, titre);
    for j := 0 to Y.Items.Count - 1 do
      if PtrInt(Y.Items.Objects[j]) = dmGenData.Query1.Fields[2].AsInteger then
        Y.ItemIndex := j;
    I.Value := dmGenData.Query1.Fields[1].AsInteger;
    case dmGenData.GetSexOfInd(i.Value)[1] of
      'M': cbxSex.ItemIndex:=1;
      'F': cbxSex.ItemIndex:=2
      else cbxSex.ItemIndex:=0
    end;
    btnOK.Enabled := True;
    TableauCitations.Enabled := True;
    M.Text := dmGenData.Query1.Fields[4].AsString;
    P.Text := dmGenData.Query1.Fields[5].AsString;
    P1.Text :=dmGenData.GetTypePhrase(PtrInt(Y.Items.Objects[Y.ItemIndex]));
    if length(P.Text) = 0 then
    begin
      P.Text := P1.Text;
      lblDefault.Visible := True;
    end;
    P2.Text := DecodePhrase(frmStemmaMainForm.iID, 'PRINCIPAL', P.Text, 'N', No.Value);
    PD2.Text := dmGenData.Query1.Fields[6].AsString;
    PD.Text := ConvertDate(dmGenData.Query1.Fields[6].AsString, 1);
    SD2.Text := dmGenData.Query1.Fields[7].AsString;
    SD.Text := ConvertDate(dmGenData.Query1.Fields[7].AsString, 1);
    X.Text := dmGenData.Query1.Fields[8].AsString;
    // Populate le tableau de citations
    dmGenData.PopulateCitations(TableauCitations, 'N', No.Value);
  end;
end;

procedure TfrmEditName.IEditingDone(Sender: TObject);
begin
  if StrToInt(I.Text) > 0 then
  begin
    btnOK.Enabled := True;
    TableauCitations.Enabled := True;
  end
  else
  begin
    btnOK.Enabled := False;
    TableauCitations.Enabled := True;
  end;
  frmStemmaMainForm.DataHist.InsertColRow(False, 0);
  frmStemmaMainForm.DataHist.Cells[0, 0] := 'I';
  frmStemmaMainForm.DataHist.Cells[1, 0] := I.Text;
end;

procedure TfrmEditName.MEditingDone(Sender: TObject);
begin
  frmStemmaMainForm.DataHist.InsertColRow(False, 0);
  frmStemmaMainForm.DataHist.Cells[0, 0] := 'M';
  frmStemmaMainForm.DataHist.Cells[1, 0] := M.Text;
end;

procedure NomSaveData;
var
  j: integer;
  parent1, parent2, no_eve, nocode, lNewIndID: longint;
  nom, i1, i2, i3, i4, temp, dateev, tagName: string;
  existe: boolean;
  sSex: Char;

begin
  nom := frmEditName.X.Text;
  nom := '';
  i1 := '';
  i2 := '';
  i3 := '';
  i4 := '';
  if frmEditName.TableauNoms.RowCount > 1 then
    for j := 1 to frmEditName.TableauNoms.RowCount - 1 do
      if length(trim(frmEditName.TableauNoms.Cells[2, j])) > 0 then
      begin
        if frmEditName.TableauNoms.Cells[1, j] = STitle then
          tagName := CTagNameTitle
        else if frmEditName.TableauNoms.Cells[1, j] = SFamilyName then
          tagName := CTagNameFamilyName
        else if frmEditName.TableauNoms.Cells[1, j] = SGivenName then
          tagName := CTagNameGivenName
        else if frmEditName.TableauNoms.Cells[1, j] = SSuffix then
          tagName := CTagNameSuffix
        else
          tagName := 'AKA';

        nom := nom + '<' + tagName + '>' + trim(frmEditName.TableauNoms.Cells[2, j]) +
          '</' + tagName + '>';
        if frmEditName.TableauNoms.Cells[1, j] = SFamilyName then
          i1 := RemoveUTF8(trim(frmEditName.TableauNoms.Cells[2, j]));
        if frmEditName.TableauNoms.Cells[1, j] = SGivenName then
          i2 := RemoveUTF8(trim(frmEditName.TableauNoms.Cells[2, j]));
      end;

  frmStemmaMainForm.DataHist.InsertColRow(False, 0);
  frmStemmaMainForm.DataHist.Cells[0, 0] := 'N';
  frmStemmaMainForm.DataHist.Cells[1, 0] := nom;


  if frmEditName.no.Value = 0 then
  begin
    //    dmGenData.GetCode(code, temp);
    case frmEditName.cbxSex.ItemIndex of
      1: sSex := 'M';
      2: sSex := 'F'
      else sSex:= '?'
    end;

    case frmEditName.EditType of
      eNET_NewUnrelated:
      begin
        lNewIndID:=dmGenData.AddNewIndividual(sSex,'?',0);
        frmEditName.I.Value:=lNewIndID ;
      end;
      eNET_AddFather, eNET_AddMother:
      begin
        lNewIndID:=dmGenData.AddNewIndividual(sSex,'?',0);
        frmEditName.I.Value := lNewIndID;
        // Valide si principal...
        dmGenData.Query2.SQL.Text :=
          'SELECT R.no, R.B FROM R JOIN I ON R.B=I.no WHERE I.S=:sex AND R.X=1 AND R.A=:idInd';
        dmGenData.Query2.ParamByName('idInd').AsInteger := frmStemmaMainForm.iID;
        if frmEditName.EditType = eNET_AddFather then
          dmGenData.Query2.ParamByName('sex').AsString := 'M'
        else
          dmGenData.Query2.ParamByName('sex').AsString := 'F';
        dmGenData.Query2.Open;
        if dmGenData.Query2.EOF then
          temp := '1'
        else
          temp := '0';

        dmGenData.RelationInsertData(10,frmStemmaMainForm.iId,frmEditName.i.Value,temp,'100000000300000000');
        // Demande si on veut unir les parents
        if (temp = '1') then
        begin
          if frmEditName.EditType = eNET_AddMother then
            temp := 'M'
          else
            temp := 'F';
          dmGenData.Query1.SQL.Text :=
            'SELECT R.no, R.B, N.N FROM R JOIN I ON R.B=I.no JOIN N on N.I=R.B WHERE I.S=:Sex AND R.X=1 AND N.X=1 AND R.A=:idInd';
          dmGenData.Query1.ParamByName('idInd').AsInteger := frmStemmaMainForm.iID;
          dmGenData.Query1.ParamByName('Sex').AsString := temp;
          dmGenData.Query1.Open;
          if not dmGenData.Query1.EOF then
          begin
            parent1 := frmEditName.I.Value;
            parent2 := dmGenData.Query1.Fields[1].AsInteger;
            // Vérifier qu'il n'y a pas déjà une union entre ces deux parents
            dmGenData.Query2.SQL.Text :=
              'SELECT COUNT(E.no) FROM E JOIN W ON W.E=E.no JOIN Y on E.Y=Y.no WHERE (W.I=:idParent1 OR W.I=:idParent2) AND W.X=1 AND E.X=1 AND Y.Y=''M'' GROUP BY E.no';
            dmGenData.Query1.ParamByName('idParent1').AsInteger := parent1;
            dmGenData.Query1.ParamByName('idParent2').AsInteger := parent2;
            dmGenData.Query2.Open;
            existe := False;
            while not dmGenData.Query2.EOF do
            begin
              existe := existe or (dmGenData.Query2.Fields[0].AsInteger = 2);
              dmGenData.Query2.Next;
            end;
            if not existe then
              // GetName(parent1) montre '???' car le nom n'a pas encore été enregistré, utiliser le nom dans 'nom'
              if Application.MessageBox(PChar(Traduction.Items[300] +
                DecodeName(nom, 1) + Traduction.Items[299] +
                DecodeName(dmGenData.Query1.Fields[2].AsString, 1) +
                Traduction.Items[28]), PChar(
                Traduction.Items[1]), MB_YESNO) = idYes then
              begin
                // Unir les parents
                // Ajouter l'événement mariage
                dmGenData.Query1.SQL.Text :=
                  'INSERT INTO E (Y, L, X) VALUES (300, 1, 1)';
                dmGenData.Query1.ExecSQL;
                no_eve := dmGenData.GetLastIDOfTable('E');
                // Ajouter les témoins
                dmGenData.Query1.SQL.Text :=
                  'INSERT INTO W (I, E, X, R) VALUES (:idInd, :idEvent,1, ''CONJOINT'')';
                dmGenData.Query1.ParamByName('idInd').AsInteger := parent1;
                dmGenData.Query1.ParamByName('idEvent').AsInteger := no_eve;
                dmGenData.Query1.ExecSQL;
                dmGenData.Query1.ParamByName('idInd').AsInteger := parent2;
                dmGenData.Query1.ParamByName('idEvent').AsInteger := no_eve;
                dmGenData.Query1.ExecSQL;
                // Ajouter les références
                // noter que l'on doit ajouter les références (frmStemmaMainForm.Code.Text='X')
                // sur l'événement # frmStemmaMainForm.no.Text
                dmGenData.PutCode('X', no_eve);
                // Sauvegarder les modifications
                dmGenData.SaveModificationTime(parent1);
                dmGenData.SaveModificationTime(parent2);
                // UPDATE DÉCÈS si la date est il y a 100 ans !!!
                if (copy(frmEditName.PD2.Text, 1, 1) = '1') and not
                  (frmEditName.PD2.Text = '100000000030000000000') then
                  dateev := Copy(frmEditName.PD2.Text, 2, 4)
                else
                if (copy(frmEditName.SD2.Text, 1, 1) = '1') and not
                  (frmEditName.SD2.Text = '100000000030000000000') then
                  dateev := Copy(frmEditName.SD2.Text, 2, 4)
                else
                  dateev := FormatDateTime('YYYY', now);
                if ((StrToInt(FormatDateTime('YYYY', now)) -
                  StrToInt(dateev)) > 100) then
                begin
                  dmGenData.Query2.SQL.Text := 'UPDATE I SET V=:Code WHERE no=:idInd';
                  dmGenData.Query2.ParamByName('idInd').AsInteger := parent1;
                  dmGenData.Query2.ParamByName('Code').AsString := 'N';
                  dmGenData.Query2.ExecSQL;
                  dmGenData.Query2.ParamByName('idInd').AsInteger := parent1;
                  dmGenData.Query2.ExecSQL;
                  dmGenData.NamesChanged(frmEditName);
                end;
                dmGenData.EventChanged(frmEditName);
              end;
          end;
        end;
      end;
      eNET_AddSpouse:
      begin
        // Trouve le sexe de la personne actuelle dans nocode...
        lNewIndID:=dmGenData.AddNewIndividual(sSex,'?',0);
        frmEditName.I.Value := lNewIndID;
        dmGenData.Query1.SQL.Clear;
        dmGenData.Query1.SQL.Add(
          'INSERT INTO E (Y, X, L, PD, SD) VALUES (300, 1, 1, ''100000000030000000000'', ''100000000030000000000'')');
        dmGenData.Query1.ExecSQL;
        nocode := dmGenData.GetLastIDOfTable('E');
        // ajouter les citations du nom à l'événement
        dmGenData.Query1.SQL.Text :=
          'INSERT INTO W (I, E, X, R) VALUES (:idInd , :idEvent ,1 , ''CONJOINT'')';
        dmGenData.Query1.ParamByName('idInd').AsInteger := frmStemmaMainForm.iID;
        dmGenData.Query1.ParamByName('idEvent').AsInteger := nocode;
        dmGenData.Query1.ExecSQL;
        //dmGenData.Query1.SQL.Clear;
        //dmGenData.Query1.SQL.Add('SHOW TABLE STATUS WHERE NAME=''E''');
        //dmGenData.Query1.Open;
        //dmGenData.Query1.First;
        // ajouter les citations du nom au témoin
        //        dmGenData.PutCode(code,dmGenData.GetLastIDOfTable('W'););
        dmGenData.Query1.SQL.Text :=
          'INSERT INTO W (I, E, X, R) VALUES (:idInd , :idEvent ,1 , ''CONJOINT'')';
        dmGenData.Query1.ParamByName('idInd').AsInteger := frmEditName.I.Value;
        dmGenData.Query1.ExecSQL;
        //dmGenData.Query1.SQL.Clear;
        //dmGenData.Query1.SQL.Add('SHOW TABLE STATUS WHERE NAME=''E''');
        //dmGenData.Query1.Open;
        //dmGenData.Query1.First;
        // ajouter les citations du nom au témoin
        //        dmGenData.PutCode(code,dmGenData.GetLastIDOfTable('W'););
        dmGenData.SaveModificationTime(frmStemmaMainForm.iID);
      end;
      eNET_AddBrother, eNET_AddSister:
      begin
        lNewIndID:=dmGenData.AddNewIndividual(sSex,'?',0);
        frmEditName.I.Value := lNewIndID;
        // Recherche parent principaux
        dmGenData.Query2.SQL.Text:='SELECT R.no, R.B FROM R WHERE R.X=1 AND R.A=' +
          frmStemmaMainForm.sID;
        dmGenData.Query2.Open;
        dmGenData.Query2.First;
        while not dmGenData.Query2.EOF do
        begin
          dmGenData.Query1.SQL.Clear;
          dmGenData.Query1.SQL.Add('INSERT INTO R (Y, A, B, X, SD) VALUES (10, ' +
            frmEditName.I.Text + ', ' + dmGenData.Query2.Fields[1].AsString +
            ', 1, ''100000000030000000000'')');
          dmGenData.Query1.ExecSQL;
          dmGenData.Query1.SQL.Clear;
          dmGenData.Query1.SQL.text:='select @@identity';
          dmGenData.Query1.Open;
          dmGenData.Query1.First;
          frmEditName.RelID:=dmGenData.Query1.Fields[0].AsInteger;
          dmGenData.Query1.SQL.Clear;
          dmGenData.Query1.SQL.Add('UPDATE I SET date=''' + FormatDateTime(
            'YYYYMMDD', now) + ''' WHERE no=' +
            dmGenData.Query2.Fields[1].AsString);
          dmGenData.Query1.ExecSQL;
          dmGenData.Query2.Next;
        end;
      end;
      eNET_AddSon, eNET_AddDaughter:
      begin
        lNewIndID:=dmGenData.AddNewIndividual(sSex,'?',0);
        frmEditName.I.Value := lNewIndID;
        dmGenData.Query1.SQL.Text :=
          'INSERT INTO R (Y, A, B, X, SD) VALUES (10, :idInd, :idInd2,1, ''100000000030000000000'')';
        dmGenData.Query1.ParamByName('idInd').AsInteger := frmEditName.I.Value;
        dmGenData.Query1.ParamByName('idInd2').AsInteger := frmStemmaMainForm.iID;
        dmGenData.Query1.ExecSQL;
        frmEditName.RelID := dmGenData.GetLastIDOfTable('R');
        // ajouter les citations du nom à la relation
        //   dmGenData.PutCode(code, );
        dmGenData.SaveModificationTime(frmStemmaMainForm.iID);
        if nocode > 0 then
        begin
          dmGenData.Query1.SQL.Text :=
            'INSERT INTO R (Y, A, B, X, SD) VALUES (10, :idInd, :idInd2,1, ''100000000030000000000'')';
          dmGenData.Query1.ParamByName('idInd').AsInteger := frmEditName.I.Value;
          dmGenData.Query1.ParamByName('idInd2').AsInteger := nocode;
          dmGenData.Query1.ExecSQL;
          // ajouter les citations du nom à la relation
          //   dmGenData.PutCode(code, dmGenData.GetLastIDOfTable('R'));
          dmGenData.SaveModificationTime(nocode);
        end;
      end
      else

    end; (*case *)
    i3 := dmGenData.GetI3(frmEditName.I.Value);
    i4 := dmGenData.GetI4(frmEditName.I.Value);
    temp := 'INSERT INTO N (Y, I, M, N, I1, I2, PD, SD, P, I3, I4, X) VALUES ' +
      '( :idEvType, :idInd, :M, :Name, :i1, :i2, :PDate, :SDate, :P, :i3, :i4, :X)';
  end  (* if frmEditName.no.Text='0' *)
  else
  begin
    // Si on déplace un nom primaire d'individu, le nom devient secondaire.
    if (frmEditName.X.Text = '1') and
      ((frmStemmaMainForm.sID <> frmEditName.I.Text) and not
      (frmEditName.I.Text = '0') and not (frmEditName.Ajout.Text = '1')) then
      frmEditName.X.Text := '0';
    temp :=
      'UPDATE N SET Y=:idEvType, I=:idInd, M=:M, N=:Name, I1=:I1, I2=:I2, PD=:PDate, SD=:SDate, P=:P, X=:X WHERE no=:idName';
  end;
  dmGenData.Query1.SQL.Text := temp;
  dmGenData.Query1.ParamByName('idEvType').AsInteger :=PtrInt(
    frmEditName.Y.Items.Objects[frmEditName.Y.ItemIndex]);
  dmGenData.Query1.ParamByName('idInd').AsInteger := frmEditName.I.Value;
  dmGenData.Query1.ParamByName('M').AsString := trim(frmEditName.M.Text);
  dmGenData.Query1.ParamByName('Name').AsString := nom;
  dmGenData.Query1.ParamByName('i1').AsString := i1;
  dmGenData.Query1.ParamByName('i2').AsString := i2;
  dmGenData.Query1.ParamByName('PDate').AsString := frmEditName.PD2.Text;
  dmGenData.Query1.ParamByName('SDate').AsString := frmEditName.SD2.Text;
  if frmEditName.lblDefault.Visible then
    dmGenData.Query1.ParamByName('P').AsString := ''
  else
    dmGenData.Query1.ParamByName('P').AsString := trim(frmEditName.P.Text);
  if frmEditName.no.Text = '0' then
  begin
    dmGenData.Query1.ParamByName('i3').AsString := i3;
    dmGenData.Query1.ParamByName('i4').AsString := i4;
  end
  else
    dmGenData.Query1.ParamByName('idName').AsInteger := frmEditName.no.Value;
  dmGenData.Query1.ParamByName('X').AsString := frmEditName.X.Text;
  dmGenData.Query1.ExecSQL;
  // Sauvegarder les modifications
  dmGenData.SaveModificationTime(frmEditName.I.Value);
  // UPDATE DÉCÈS si la date est il y a 100 ans !!!
  if (copy(frmEditName.PD2.Text, 1, 1) = '1') and not
    (frmEditName.PD2.Text = '100000000030000000000') then
    dateev := Copy(frmEditName.PD2.Text, 2, 4)
  else
  if (copy(frmEditName.SD2.Text, 1, 1) = '1') and not
    (frmEditName.SD2.Text = '100000000030000000000') then
    dateev := Copy(frmEditName.SD2.Text, 2, 4)
  else
    dateev := FormatDateTime('YYYY', now);
  if ((StrToInt(FormatDateTime('YYYY', now)) - StrToInt(dateev)) > 100) then
  begin
    dmGenData.Query2.SQL.Text:='UPDATE I SET V=''N'' WHERE no=' + frmEditName.I.Text;
    dmGenData.Query2.ExecSQL;
    frmNames.PopulateNom(frmNames);
  end;
  if not (frmEditName.I.Text = frmStemmaMainForm.sID) then
    dmGenData.SaveModificationTime(frmStemmaMainForm.iID);
  // Modifier la ligne de l'explorateur
  if frmStemmaMainForm.mniExplorateur.Checked then
    if frmEditName.no.Text <> '0' then
    begin
      for j := 1 to frmExplorer.Index.RowCount - 1 do
        if frmExplorer.Index.Cells[0, j] = frmEditName.no.Text then
        begin
          frmExplorer.Index.Cells[1, j] := frmEditName.I.Text;
          if frmExplorer.O.Text = '1' then
            frmExplorer.Index.Cells[2, j] := DecodeName(nom, 1)
          else
            frmExplorer.Index.Cells[2, j] := DecodeName(nom, 2);
          if frmExplorer.O.Text = '1' then
            frmExplorer.Index.Cells[6, j] := RemoveUTF8(i2 + ' ' + i1);
          if frmExplorer.O.Text = '2' then
            frmExplorer.Index.Cells[6, j] := RemoveUTF8(i1 + ', ' + i2);
          if (frmExplorer.O.Text = '1') or (frmExplorer.O.Text = '2') then
          begin
            //                 frmExplorer.Index.SortColRow(true,6);
            frmExplorer.TrouveIndividu;
          end;
          break;
        end;
    end
    else
    begin
      if frmExplorer.O.Text = '1' then
        temp := RemoveUTF8(i2 + ' ' + i1);
      if frmExplorer.O.Text = '2' then
        temp := RemoveUTF8(i1 + ', ' + i2);
      if frmExplorer.O.Text = '3' then
        temp := dmGenData.geti3(frmEditName.I.Value);
      if frmExplorer.O.Text = '4' then
        temp := dmGenData.geti4(frmEditName.I.Value);
      if length(temp) > 0 then
      begin
        j := frmExplorer.Index.Row;
        if AnsiCompareText((copy(frmExplorer.Index.Cells[6, j],
          1, length(temp))), temp) > 0 then
        begin
          while (AnsiCompareText(
              (copy(frmExplorer.Index.Cells[6, j], 1, length(temp))), temp) > 0) and
            (j > 1) do
          begin
            Application.ProcessMessages;
            j := j - 1;
          end;
          j := j + 1;
        end
        else
        begin
          while (AnsiCompareText(
              (copy(frmExplorer.Index.Cells[6, j], 1, length(temp))), temp) < 0) and
            (j < frmExplorer.index.rowcount - 1) do
          begin
            Application.ProcessMessages;
            j := j + 1;
          end;
          j := j - 1;
        end;
      end;
      frmExplorer.Index.InsertColRow(False, j);
      dmGenData.Query1.SQL.Text:='SHOW TABLE STATUS WHERE NAME=''N''';
      dmGenData.Query1.Open;
      dmGenData.Query1.First;
      frmEditName.no.Text := IntToStr(dmGenData.Query1.Fields[10].AsInteger - 1);
      frmExplorer.Index.Cells[0, j] := frmEditName.no.Text;
      frmExplorer.Index.Cells[1, j] := frmEditName.I.Text;
      if frmExplorer.O.Text = '1' then
        frmExplorer.Index.Cells[2, j] := DecodeName(nom, 1)
      else
        frmExplorer.Index.Cells[2, j] := DecodeName(nom, 2);
      frmExplorer.Index.Cells[3, j] := ConvertDate(i3, 1);
      frmExplorer.Index.Cells[4, j] := ConvertDate(i4, 1);
      if frmEditName.X.Text = '1' then
        frmExplorer.Index.Cells[5, j] := '*'
      else
        frmExplorer.Index.Cells[5, j] := '';
      frmExplorer.Index.Cells[6, j] := temp;
      frmExplorer.Index.Row := j;
      //        frmExplorer.Index.SortColRow(true,6);
      //        TrouveIndividu;
    end;
  if frmEditName.no.Value = 0 then
  begin
    frmEditName.no.Value := dmGenData.GetLastIDOfTable('N');
  end;
end;

procedure TfrmEditName.btnOKClick(Sender: TObject);

begin
  if frmEditName.ActiveControl is TEdit and assigned(
    (frmEditName.ActiveControl as TEdit).OnEditingDone) then
    (frmEditName.ActiveControl as TEdit).OnEditingDone(frmEditName.ActiveControl);
  NomSaveData;
  case FEditType of
    eNET_EditExisting:
    begin
      dmGenData.Query1.SQL.Text := 'SELECT S, Q, M FROM C WHERE Y=''N'' AND N=:idInd';
      dmgenData.Query1.ParamByName('idInd').AsInteger := no.Value;
      dmGenData.Query1.Open;
      dmGenData.Query1.First;
      while not dmGenData.Query1.EOF do
      begin
        dmGenData.Query2.SQL.Text :=
          'INSERT INTO C (Y, N, S, Q, M) VALUES (''E'', :idInd, :S, :Q, :M)';
        dmgenData.Query2.ParamByName('idInd').AsInteger := i.Value;
        dmgenData.Query2.ParamByName('S').AsString := dmGenData.Query1.Fields[0].AsString;
        dmgenData.Query2.ParamByName('Q').AsString := dmGenData.Query1.Fields[1].AsString;
        dmgenData.Query2.ParamByName('M').AsString := dmGenData.Query1.Fields[2].AsString;
        dmGenData.Query2.ExecSQL;
        dmGenData.Query1.Next;
      end;
      //    dmGenData.GetCode(code, nocode);
    end;
    eNET_AddSpouse:  //Spouse
    begin
      dmGenData.Query1.SQL.Text := 'SELECT S, Q, M FROM C WHERE Y=''N'' AND N=:idInd';
      dmgenData.Query1.ParamByName('idInd').AsInteger := no.Value;
      dmGenData.Query1.Open;
      dmGenData.Query1.First;
      while not dmGenData.Query1.EOF do
      begin
        dmGenData.Query2.SQL.Text :=
          'INSERT INTO C (Y, N, S, Q, M) VALUES (''E'', :idInd, :S, :Q, :M)';
        dmgenData.Query2.ParamByName('idInd').AsInteger := i.Value;
        dmgenData.Query2.ParamByName('S').AsString := dmGenData.Query1.Fields[0].AsString;
        dmgenData.Query2.ParamByName('Q').AsString := dmGenData.Query1.Fields[1].AsString;
        dmgenData.Query2.ParamByName('M').AsString := dmGenData.Query1.Fields[2].AsString;
        dmGenData.Query2.ExecSQL;
        dmGenData.Query1.Next;
      end;
    end;
    eNET_AddMother, eNET_AddFather: //Father or Mother
    begin
      dmGenData.Query1.SQL.Text := 'SELECT S, Q, M FROM C WHERE Y=''N'' AND N=:idInd';
      dmgenData.Query1.ParamByName('idInd').AsInteger := no.Value;
      dmGenData.Query1.Open;
      dmGenData.Query1.First;
      while not dmGenData.Query1.EOF do
      begin
        dmGenData.Query2.SQL.Text :=
          'INSERT INTO C (Y, N, S, Q, M) VALUES (''R'', :idInd, :S, :Q, :M)';
        dmgenData.Query2.ParamByName('idInd').AsInteger := i.Value;
        dmgenData.Query2.ParamByName('S').AsString := dmGenData.Query1.Fields[0].AsString;
        dmgenData.Query2.ParamByName('Q').AsString := dmGenData.Query1.Fields[1].AsString;
        dmgenData.Query2.ParamByName('M').AsString := dmGenData.Query1.Fields[2].AsString;
        dmGenData.Query2.ExecSQL;
        dmGenData.Query1.Next;
      end;
    end;
    eNET_AddBrother, eNET_AddSister:  //Brother or Sister
    begin
      dmGenData.Query1.SQL.Text := 'SELECT S, Q, M FROM C WHERE Y=''N'' AND N=:idInd';
      dmgenData.Query1.ParamByName('idInd').AsInteger := no.Value;
      dmGenData.Query1.Open;
      dmGenData.Query1.First;
      while not dmGenData.Query1.EOF do
      begin
        dmGenData.Query2.SQL.Text :=
          'INSERT INTO C (Y, N, S, Q, M) VALUES (''R'', :idInd, :S, :Q, :M)';
        dmgenData.Query2.ParamByName('idInd').AsInteger := i.Value;
        dmgenData.Query2.ParamByName('S').AsString := dmGenData.Query1.Fields[0].AsString;
        dmgenData.Query2.ParamByName('Q').AsString := dmGenData.Query1.Fields[1].AsString;
        dmgenData.Query2.ParamByName('M').AsString := dmGenData.Query1.Fields[2].AsString;
        dmGenData.Query2.ExecSQL;
        dmGenData.Query1.Next;
      end;
    end;
    eNET_AddSon, eNET_AddDaughter:  // Son or Daughter
    begin
      dmGenData.Query1.SQL.Text := 'SELECT S, Q, M FROM C WHERE Y=''N'' AND N=:idInd';
      dmgenData.Query1.ParamByName('idInd').AsInteger := no.Value;
      dmGenData.Query1.Open;
      dmGenData.Query1.First;
      while not dmGenData.Query1.EOF do
      begin
        dmGenData.Query2.SQL.Text :=
          'INSERT INTO C (Y, N, S, Q, M) VALUES (''R'', :idInd, :S, :Q, :M)';
        dmgenData.Query2.ParamByName('idInd').AsInteger := i.Value;
        dmgenData.Query2.ParamByName('S').AsString := dmGenData.Query1.Fields[0].AsString;
        dmgenData.Query2.ParamByName('Q').AsString := dmGenData.Query1.Fields[1].AsString;
        dmgenData.Query2.ParamByName('M').AsString := dmGenData.Query1.Fields[2].AsString;
        dmGenData.Query2.ExecSQL;
        dmGenData.Query1.Next;
      end;
    end;
  end;
end;

procedure TfrmEditName.edtNameExit(Sender: TObject);
begin

end;

procedure TfrmEditName.Ajouter1Click(Sender: TObject);
begin
  if btnOK.Enabled then
  begin
    if no.Value = 0 then
      NomSaveData;
    dmGenData.PutCode('N', no.Value);
    dmGenData.PutCode('A', no.Value);
    if EditCitations.Showmodal = mrOk then
      dmGenData.PopulateCitations(TableauCitations, 'N', No.Value);
  end;
end;

procedure TfrmEditName.MenuItem1Click(Sender: TObject);
var
  j: integer;
  existe: boolean;
begin
  // Ajouter Titre
  if TableauNoms.RowCount > 1 then
    existe := TableauNoms.Cells[1, TableauNoms.RowCount - 1] =
      Traduction.Items[40]
  else
    existe := False;
  if not existe then
  begin
    TableauNoms.RowCount := TableauNoms.RowCount + 1;
    if TableauNoms.RowCount > 2 then
      for j := TableauNoms.RowCount - 1 downto 1 do
      begin
        TableauNoms.Cells[1, j] := TableauNoms.Cells[1, j - 1];
        TableauNoms.Cells[2, j] := TableauNoms.Cells[2, j - 1];
      end;
    TableauNoms.Cells[1, 1] := Traduction.Items[40];
    TableauNoms.Cells[2, 1] := '';
    TableauNoms.Row := 1;
    TableauNoms.Col := 2;
    frmEditName.ActiveControl := TableauNoms;
  end;
end;

procedure TfrmEditName.MenuItem2Click(Sender: TObject);
var
  j: integer;
  existe: boolean;
begin
  // Ajouter Prénom
  existe := False;
  if TableauNoms.RowCount > 1 then
    for j := 1 to TableauNoms.RowCount - 1 do
      existe := existe or (TableauNoms.Cells[1, j] = Traduction.Items[38]);
  if not existe then
  begin
    TableauNoms.RowCount := TableauNoms.RowCount + 1;
    if TableauNoms.Cells[1, 1] = STitle then
    begin
      if TableauNoms.RowCount > 3 then
        for j := TableauNoms.RowCount - 1 downto 2 do
        begin
          TableauNoms.Cells[1, j] := TableauNoms.Cells[1, j - 1];
          TableauNoms.Cells[2, j] := TableauNoms.Cells[2, j - 1];
        end;
      TableauNoms.Cells[1, 2] := Traduction.Items[38];
      TableauNoms.Cells[2, 2] := '';
      TableauNoms.Row := 2;
    end
    else
    begin
      if TableauNoms.RowCount > 2 then
        for j := TableauNoms.RowCount - 1 downto 1 do
        begin
          TableauNoms.Cells[1, j] := TableauNoms.Cells[1, j - 1];
          TableauNoms.Cells[2, j] := TableauNoms.Cells[2, j - 1];
        end;
      TableauNoms.Cells[1, 1] := Traduction.Items[38];
      TableauNoms.Cells[2, 1] := '';
      TableauNoms.Row := 1;
    end;
    TableauNoms.Col := 2;
    frmEditName.ActiveControl := TableauNoms;
  end;
end;

procedure TfrmEditName.MenuItem3Click(Sender: TObject);
var
  j: integer;
  existe: boolean;
begin
  // Ajouter Nom
  existe := False;
  if TableauNoms.RowCount > 1 then
    for j := 1 to TableauNoms.RowCount - 1 do
      existe := existe or (TableauNoms.Cells[1, j] = Traduction.Items[37]);
  if not existe then
  begin
    TableauNoms.RowCount := TableauNoms.RowCount + 1;
    if TableauNoms.Cells[1, TableauNoms.RowCount - 2] =
      Traduction.Items[39] then
    begin
      TableauNoms.Cells[1, TableauNoms.RowCount - 1] :=
        TableauNoms.Cells[1, TableauNoms.RowCount - 2];
      TableauNoms.Cells[2, TableauNoms.RowCount - 1] :=
        TableauNoms.Cells[2, TableauNoms.RowCount - 2];
      TableauNoms.Cells[1, TableauNoms.RowCount - 2] := Traduction.Items[37];
      TableauNoms.Cells[2, TableauNoms.RowCount - 2] := '';
      TableauNoms.Row := TableauNoms.RowCount - 2;
    end
    else
    begin
      TableauNoms.Cells[1, TableauNoms.RowCount - 1] := Traduction.Items[37];
      TableauNoms.Cells[2, TableauNoms.RowCount - 1] := '';
      TableauNoms.Row := TableauNoms.RowCount - 1;
    end;
    TableauNoms.Col := 2;
    frmEditName.ActiveControl := TableauNoms;
  end;
end;

procedure TfrmEditName.MenuItem4Click(Sender: TObject);
var
  existe: boolean;
begin
  // Ajouter Suffixe
  if TableauNoms.RowCount > 1 then
    existe := TableauNoms.Cells[1, TableauNoms.RowCount - 1] =
      Traduction.Items[39]
  else
    existe := False;
  if not existe then
  begin
    TableauNoms.RowCount := TableauNoms.RowCount + 1;
    TableauNoms.Cells[1, TableauNoms.RowCount - 1] := Traduction.Items[39];
    TableauNoms.Cells[2, TableauNoms.RowCount - 1] := '';
    TableauNoms.Row := TableauNoms.RowCount - 1;
    TableauNoms.Col := 2;
    frmEditName.ActiveControl := TableauNoms;
  end;
end;

procedure TfrmEditName.MenuItem5Click(Sender: TObject);
begin
  btnOKClick(Sender);
  ModalResult := mrOk;
end;

procedure TfrmEditName.MenuItem6Click(Sender: TObject);
var
  j : integer;
  found: boolean;
  temp, nom, titre, prenom, suffixe: string;
begin
  if frmEditName.ActiveControl.Name = 'TableauNoms' then
  begin
    found := False;
    for j := frmStemmaMainForm.DataHist.Row to frmStemmaMainForm.DataHist.RowCount - 1 do
    begin
      if frmStemmaMainForm.DataHist.Cells[0, j] = 'N' then
      begin
        // Traitement de F3 pour les noms }
        temp := frmStemmaMainForm.DataHist.Cells[0, j];
        DecodeFullName(temp,suffixe,nom,prenom,titre);
        FillNameTable(suffixe, nom, prenom,titre);
        found := True;
        break;
      end;
    end;
    if not found then
    begin
      for j := 0 to frmStemmaMainForm.DataHist.RowCount - 1 do
      begin
        if frmStemmaMainForm.DataHist.Cells[0, j] = 'N' then
        begin
          // Traitement de F3 pour les noms }
          temp := frmStemmaMainForm.DataHist.Cells[0, j];
          DecodeFullName(temp,suffixe,nom,prenom,titre);
          FillNameTable(suffixe, nom, prenom,titre);
          found := True;
          break;
        end;
      end;
    end;
  end;
  if frmEditName.ActiveControl.Name = 'SD' then
  begin
    found := False;
    for j := frmStemmaMainForm.DataHist.Row to frmStemmaMainForm.DataHist.RowCount - 1 do
    begin
      if frmStemmaMainForm.DataHist.Cells[0, j] = 'SD' then
      begin
        SD.Text := frmStemmaMainForm.DataHist.Cells[1, j];
        SDEditingDone(Sender);
        found := True;
        break;
      end;
    end;
    if not found then
    begin
      for j := 0 to frmStemmaMainForm.DataHist.RowCount - 1 do
      begin
        if frmStemmaMainForm.DataHist.Cells[0, j] = 'SD' then
        begin
          SD.Text := frmStemmaMainForm.DataHist.Cells[1, j];
          SDEditingDone(Sender);
          found := True;
          break;
        end;
      end;
    end;
  end;
  if frmEditName.ActiveControl.Name = 'PD' then
  begin
    found := False;
    for j := frmStemmaMainForm.DataHist.Row to frmStemmaMainForm.DataHist.RowCount - 1 do
    begin
      if frmStemmaMainForm.DataHist.Cells[0, j] = 'PD' then
      begin
        PD.Text := frmStemmaMainForm.DataHist.Cells[1, j];
        PDEditingDone(Sender);
        found := True;
        break;
      end;
    end;
    if not found then
    begin
      for j := 0 to frmStemmaMainForm.DataHist.RowCount - 1 do
      begin
        if frmStemmaMainForm.DataHist.Cells[0, j] = 'PD' then
        begin
          PD.Text := frmStemmaMainForm.DataHist.Cells[1, j];
          PDEditingDone(Sender);
          found := True;
          break;
        end;
      end;
    end;
  end;
  if frmEditName.ActiveControl.Name = 'I' then
  begin
    found := False;
    for j := frmStemmaMainForm.DataHist.Row to frmStemmaMainForm.DataHist.RowCount - 1 do
    begin
      if frmStemmaMainForm.DataHist.Cells[0, j] = 'I' then
      begin
        I.Text := frmStemmaMainForm.DataHist.Cells[1, j];
        IEditingDone(Sender);
        found := True;
        break;
      end;
    end;
    if not found then
    begin
      for j := 0 to frmStemmaMainForm.DataHist.RowCount - 1 do
      begin
        if frmStemmaMainForm.DataHist.Cells[0, j] = 'A' then
        begin
          I.Text := frmStemmaMainForm.DataHist.Cells[1, j];
          IEditingDone(Sender);
          found := True;
          break;
        end;
      end;
    end;
  end;
  if frmEditName.ActiveControl.Name = 'P' then
  begin
    found := False;
    for j := frmStemmaMainForm.DataHist.Row to frmStemmaMainForm.DataHist.RowCount - 1 do
    begin
      if frmStemmaMainForm.DataHist.Cells[0, j] = 'P' then
      begin
        P.Text := frmStemmaMainForm.DataHist.Cells[1, j];
        PEditingDone(Sender);
        found := True;
        break;
      end;
    end;
    if not found then
    begin
      for j := 0 to frmStemmaMainForm.DataHist.RowCount - 1 do
      begin
        if frmStemmaMainForm.DataHist.Cells[0, j] = 'P' then
        begin
          P.Text := frmStemmaMainForm.DataHist.Cells[1, j];
          PEditingDone(Sender);
          found := True;
          break;
        end;
      end;
    end;
  end;
  if frmEditName.ActiveControl.Name = 'M' then
  begin
    found := False;
    for j := frmStemmaMainForm.DataHist.Row to frmStemmaMainForm.DataHist.RowCount - 1 do
    begin
      if frmStemmaMainForm.DataHist.Cells[0, j] = 'M' then
      begin
        M.Text := frmStemmaMainForm.DataHist.Cells[1, j];
        found := True;
        break;
      end;
    end;
    if not found then
    begin
      for j := 0 to frmStemmaMainForm.DataHist.RowCount - 1 do
      begin
        if frmStemmaMainForm.DataHist.Cells[0, j] = 'M' then
        begin
          M.Text := frmStemmaMainForm.DataHist.Cells[1, j];
          found := True;
          break;
        end;
      end;
    end;
  end;
  if found then
    frmStemmaMainForm.DataHist.Row := j + 1;
end;

procedure TfrmEditName.PDblClick(Sender: TObject);
begin
  P2.Visible := True;
  P.Visible := False;
end;

procedure TfrmEditName.PDEditingDone(Sender: TObject);
begin
  PD2.Text := InterpreteDate(PD.Text, 1);
  PD.Text := ConvertDate(PD2.Text, 1);
  SD.Text := PD.Text;
  SD2.Text := PD2.Text;
  frmStemmaMainForm.DataHist.InsertColRow(False, 0);
  frmStemmaMainForm.DataHist.Cells[0, 0] := 'PD';
  frmStemmaMainForm.DataHist.Cells[1, 0] := PD2.Text;
end;

procedure TfrmEditName.PEditingDone(Sender: TObject);
begin
  if length(P.Text) = 0 then
    P.Text := P1.Text;
  lblDefault.Visible := (P.Text = P1.Text);
  P2.Text := DecodePhrase(frmStemmaMainForm.sID, 'TEMOIN', P.Text, 'N', No.Text);
  frmStemmaMainForm.DataHist.InsertColRow(False, 0);
  frmStemmaMainForm.DataHist.Cells[0, 0] := 'P';
  frmStemmaMainForm.DataHist.Cells[1, 0] := P.Text;
end;

procedure TfrmEditName.SDEditingDone(Sender: TObject);
begin
  SD2.Text := InterpreteDate(SD.Text, 1);
  SD.Text := ConvertDate(SD2.Text, 1);
  frmStemmaMainForm.DataHist.InsertColRow(False, 0);
  frmStemmaMainForm.DataHist.Cells[0, 0] := 'SD';
  frmStemmaMainForm.DataHist.Cells[1, 0] := SD2.Text;
end;

procedure TfrmEditName.Supprimer1Click(Sender: TObject);
begin
  if TableauCitations.Row > 0 then
    if Application.MessageBox(PChar(Traduction.Items[31] +
      TableauCitations.Cells[1, TableauCitations.Row] +
      Traduction.Items[28]), PChar(Traduction.Items[1]),
      MB_YESNO) = idYes then
    begin
      dmGenData.Query1.SQL.Text:='DELETE FROM C WHERE no=' +
        TableauCitations.Cells[0, TableauCitations.Row];
      dmGenData.Query1.ExecSQL;
      TableauCitations.DeleteRow(TableauCitations.Row);
      dmGenData.SaveModificationTime(I.Value);
    end;
end;

end.