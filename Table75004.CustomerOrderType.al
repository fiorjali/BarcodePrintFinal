table 75004 "Customer Order Type"
{
    Caption = 'Customer Order Type';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = ToBeClassified;
            Editable = false;
            AutoIncrement = true;
        }
        field(2; "Sell To Customer No."; Code[20])
        {
            Caption = 'Sell To Customer  No.';
            DataClassification = ToBeClassified;
            TableRelation = Customer;

            trigger OnValidate()
            var
                CustRec: Record Customer;
                CustFindRec: Record Customer;
            begin
                if CustRec.get("Sell To Customer No.") then begin
                    "Sell To Customer Name" := CustRec.Name;
                    "Bill To Customer No." := CustRec."Bill-to Customer No.";

                    if CustFindRec.get(CustRec."Bill-to Customer No.") then begin
                        "Bill To Customer Name" := CustFindRec.Name;
                    end;
                end;
            end;

        }
        field(3; "Sell To Customer Name"; Text[100])
        {
            Caption = 'Sell To Customer Name';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(4; "Bill To Customer No."; Code[20])
        {
            Caption = 'Bill To Customer No.';
            DataClassification = ToBeClassified;
            TableRelation = Customer;

        }
        field(5; "Bill To Customer Name"; Text[100])
        {
            Caption = 'Bill To Customer Name';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(6; UOM; Code[20])
        {
            Caption = 'UOM';
            DataClassification = ToBeClassified;
            TableRelation = "Unit of Measure";
        }
        field(7; "Active Yes/No"; Boolean)
        {
            Caption = 'Active Yes/No';
            DataClassification = ToBeClassified;
        }
        field(8; "Order Type"; Option)
        {
            Caption = 'Order Type';
            DataClassification = ToBeClassified;
            OptionMembers = Deafult,Regular,BCD,Mask,Nightwear;
        }
        field(9; Remarks; Text[250])
        {
            Caption = 'Remarks';
            DataClassification = ToBeClassified;
        }
        field(12; "Created Date"; Date)
        {
            Caption = 'Created Date';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(13; "Created Time"; Time)
        {
            Caption = 'Created Time';
            DataClassification = ToBeClassified;
            Editable = false;
        }


    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        "Created Date" := Today;
        "Created Time" := Time;
    end;

}
