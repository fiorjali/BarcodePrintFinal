page 75009 SaleOrderMobileApp
{
    ApplicationArea = All;
    Caption = 'SaleOrderMobileApp';
    PageType = List;
    SourceTable = SaleOrderMobileApp;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                }
                field(S_75; Rec.S_75)
                {
                    ApplicationArea = All;
                }
                field(S_80S; Rec.S_80S)
                {
                    ApplicationArea = All;
                }
                field(S_85M; Rec.S_85M)
                {
                    ApplicationArea = All;
                }
                field(S_90L; Rec.S_90L)
                {
                    ApplicationArea = All;
                }
                field(S_95XL; Rec.S_95XL)
                {
                    ApplicationArea = All;
                }
                field(S_1002XL; Rec.S_1002XL)
                {
                    ApplicationArea = All;
                }
                field(S_1053XL; Rec.S_1053XL)
                {
                    ApplicationArea = All;
                }
                field(S_1104XL; Rec.S_1104XL)
                {
                    ApplicationArea = All;
                }
                field(S_1155XL; Rec.S_1155XL)
                {
                    ApplicationArea = All;
                }
                field("Tota Qty"; Rec."Tota Qty")
                {
                    ApplicationArea = All;
                }
                field("Sell To Customer"; Rec."Sell To Customer")
                {
                    ApplicationArea = All;
                }
                field("Bill To Customer"; Rec."Bill To Customer")
                {
                    ApplicationArea = All;
                }
                field(Remark; Rec.Remark)
                {
                    ApplicationArea = All;
                }
                field("Item Category Code"; Rec."Item Category Code")
                {
                    ApplicationArea = All;
                }
                field("Sale Order No."; Rec."Sale Order No.")
                {
                    ApplicationArea = All;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                }
                field("Created Date"; Rec."Created Date")
                {
                    ApplicationArea = All;
                }
                field("Created Time"; Rec."Created Time")
                {
                    ApplicationArea = All;
                }
                field("Accepted Date"; Rec."Accepted Date")
                {
                    ApplicationArea = All;
                }
                field("Accepted Time"; Rec."Accepted Time")
                {
                    ApplicationArea = All;
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                }
                field("Serial No."; Rec."Serial No.")
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
                field("Store Name"; Rec."Store Name")
                {
                    ApplicationArea = All;
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
