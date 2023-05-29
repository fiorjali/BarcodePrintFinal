table 75000 "Item Category App"
{
    Caption = 'Item Category App';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = ToBeClassified;
            //AutoIncrement = true;
        }
        field(2; "Catagory Code"; Code[50])
        {
            Caption = 'Catagory Code';
            DataClassification = ToBeClassified;
        }
        field(3; "Catagory Name"; Text[250])
        {
            Caption = 'Catagory Name';
            DataClassification = ToBeClassified;
        }
        field(4; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = ToBeClassified;
        }
        field(5; Remark; Text[250])
        {
            Caption = 'Remark';
            DataClassification = ToBeClassified;
        }

    }
    keys
    {
        key(PK; "Catagory Code")
        {
            Clustered = true;

        }
    }
}
