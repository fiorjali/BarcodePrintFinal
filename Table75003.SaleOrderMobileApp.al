table 75003 SaleOrderMobileApp
{
    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            DataClassification = ToBeClassified;
        }
        field(2; "Customer No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Customer."No." where(Blocked = filter(" "));
        }
        field(3; "Item No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Item."No." where(Blocked = filter(False));
        }
        field(4; S_75; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(5; S_80S; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(6; S_85M; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(7; S_90L; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(8; S_95XL; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(9; S_1002XL; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(10; S_1053XL; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(11; S_1104XL; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(12; S_1155XL; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(13; "Tota Qty"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(14; "Item Category Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(15; Remark; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(16; "Created Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(17; "Created Time"; Time)
        {
            DataClassification = ToBeClassified;
        }
        field(18; "Accepted Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(19; "Accepted Time"; Time)
        {
            DataClassification = ToBeClassified;
        }
        field(20; Status; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Pending,Accepted,Error';
            OptionMembers = Pending,Accepted,Error;
        }
        field(21; "Sale Order No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(22; "Document No."; Code[30])
        {
        }
        field(23; "Serial No."; Integer)
        {
        }
        field(24; "Bill To Customer"; Code[20])
        {
        }

        field(25; "Sell To Customer"; Code[20])
        {
        }

        field(26; "User ID"; Code[50])
        {
        }
        field(27; "Store Name"; Code[50])
        {

        }


    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin

        "Created Date" := TODAY;
        "Created Time" := TIME;

        "Tota Qty" := S_75 + S_80S + S_85M + S_90L + S_95XL + S_1002XL + S_1053XL + S_1104XL + S_1155XL;

        /* CustomerOrderTypeRec.RESET;
        CustomerOrderTypeRec.SETRANGE("Sell To Customer", "Customer No.");
        CustomerOrderTypeRec.SETRANGE("Order Type", "Order Type");


        IF "Order Type" = "Order Type"::Deafult THEN BEGIN
            IF (CustomerRec.GET("Customer No.")) THEN BEGIN
                "Bill To Customer" := CustomerRec."Bill-to Customer No.";
            END;
        END ELSE BEGIN
            IF CustomerOrderTypeRec.FINDFIRST THEN BEGIN
                "Bill To Customer" := CustomerOrderTypeRec."Bill To Customer";
            END;
        END; */

    end;

    var
        // CustomerOrderTypeRec: Record 50047;
        CustomerRec: Record 18;
}
