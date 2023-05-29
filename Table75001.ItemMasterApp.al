table 75001 "Item Master App"
{
    Caption = 'Item Master App';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = ToBeClassified;
            TableRelation = "Item";

            trigger OnValidate()
            VAR
                ItemRec: Record "Item";
            begin
                if ItemRec.Get("Item No.") then begin
                    Rec.Name := ItemRec.Description;
                end;
            end;

        }
        field(2; Name; Text[250])
        {
            Caption = 'Name';
            DataClassification = ToBeClassified;
        }
        field(3; "Item Size"; Code[50])
        {
            Caption = 'Item Size';
            DataClassification = ToBeClassified;
        }
        field(4; "Catagory Code"; Code[50])
        {
            Caption = 'Catagory Code';
            DataClassification = ToBeClassified;
            TableRelation = "Item Category App"."Catagory Code";

        }
        field(5; "Image URL"; Text[1024])
        {
            Caption = 'Image URL';
            DataClassification = ToBeClassified;
        }
        field(6; Remark; Text[2024])
        {
            Caption = 'Remark';
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; "Item No.")
        {
            Clustered = true;
        }
    }
    
}
