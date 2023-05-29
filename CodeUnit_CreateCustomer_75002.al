codeunit 75002 "Create Customer"
{
    TableNo = "Web User";

    var
        WebUserRec: Record "Web User";

    trigger OnRun()
    begin
        WebUserRec.Init();
        WebUserRec."User ID" := Rec."User ID" + 'ajslfdjdalf flsajfsa;jfsajflasflsaasjfdldasjf;lsajfsalj';
        WebUserRec.Password := Rec.Password;
        WebUserRec.Insert(True);
    end;




}