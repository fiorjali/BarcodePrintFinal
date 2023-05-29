table 75002 SaleOrderExport
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
        field(14; "Select Order Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ',Pluse Balance,New Order (Balance Cancel)';
            OptionMembers = ,"Pluse Balance","New Order (Balance Cancel)";

        }
        field(15; "Item Category Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(16; Remark; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(17; "Created Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(18; "Created Time"; Time)
        {
            DataClassification = ToBeClassified;
        }
        field(19; "Accepted Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(20; "Accepted Time"; Time)
        {
            DataClassification = ToBeClassified;
        }
        field(21; Status; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Pending,Accepted,Error';
            OptionMembers = Pending,Accepted,Error;
        }
        field(22; "Sale Order No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(23; "Document No."; Code[30])
        {
        }
        field(24; "Serial No."; Integer)
        {
        }
        field(25; "Order Type"; Option)
        {
            OptionCaption = 'Deafult,Regular,BCD,Mask,Nightwear';
            OptionMembers = Deafult,Regular,BCD,Mask,Nightwear;
        }
        field(26; "Bill To Customer"; Code[20])
        {

        }

        field(27; "User ID"; Code[100])
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
        if (rec."Document No." = '') then begin
            Message('Document No Can not Blank ');
        end;
        "Created Date" := TODAY;
        "Created Time" := TIME;

        "Tota Qty" := S_75 + S_80S + S_85M + S_90L + S_95XL + S_1002XL + S_1053XL + S_1104XL + S_1155XL;

        CustomerOrderTypeRec.RESET;
        CustomerOrderTypeRec.SETRANGE("Sell To Customer No.", "Customer No.");
        CustomerOrderTypeRec.SETRANGE("Order Type", "Order Type");


        IF "Order Type" = "Order Type"::Deafult THEN BEGIN
            IF (CustomerRec.GET("Customer No.")) THEN BEGIN
                "Bill To Customer" := CustomerRec."Bill-to Customer No.";
            END;
        END ELSE BEGIN
            IF CustomerOrderTypeRec.FINDFIRST THEN BEGIN
                "Bill To Customer" := CustomerOrderTypeRec."Bill To Customer No.";
            END;
        END;

        //Update Serial No.
        if "Serial No." = 0 then begin
            SaleOrderExportRec.Reset();
            SaleOrderExportRec.SetRange("Document No.", Rec."Document No.");
            if SaleOrderExportRec.FindLast() then begin
                "Serial No." := SaleOrderExportRec."Serial No." + 1;
            end else begin
                "Serial No." := 1;
            end;
        end;

    end;

    var

        CustomerOrderTypeRec: Record "Customer Order Type";
        CustomerRec: Record Customer;
        SaleOrderExportRec: Record SaleOrderExport;

}
