page 75008 SaleOrderExportAPI
{
    APIGroup = 'BCPL';
    APIPublisher = 'BCPLWebApp';
    APIVersion = 'v1.0';
    Caption = 'SaleOrderExportAPI';
    DelayedInsert = true;
    EntityName = 'SaleOrderExport';
    EntitySetName = 'SaleOrderExportAPI';
    PageType = API;
    SourceTable = SaleOrderExport;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(documentNo; Rec."Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document No. field.';
                }
                field(customerNo; Rec."Customer No.")
                {
                    Caption = 'Customer No.';
                }
                field(itemNo; Rec."Item No.")
                {
                    Caption = 'Item No.';
                }
                field(s75; Rec.S_75)
                {
                    Caption = 'S_75';
                }
                field(s80S; Rec.S_80S)
                {
                    Caption = 'S_80S';
                }
                field(s85M; Rec.S_85M)
                {
                    Caption = 'S_85M';
                }
                field(s90L; Rec.S_90L)
                {
                    Caption = 'S_90L';
                }
                field(s95XL; Rec.S_95XL)
                {
                    Caption = 'S_95XL';
                }
                field(s1002XL; Rec.S_1002XL)
                {
                    Caption = 'S_1002XL';
                }
                field(s1053XL; Rec.S_1053XL)
                {
                    Caption = 'S_1053XL';
                }
                field(s1104XL; Rec.S_1104XL)
                {
                    Caption = 'S_1104XL';
                }
                field(s1155XL; Rec.S_1155XL)
                {
                    Caption = 'S_1155XL';
                }

                field(orderType; Rec."Order Type")
                {
                    Caption = 'Order Type';
                }
                field(selectOrderType; Rec."Select Order Type")
                {
                    Caption = 'Select Order Type';
                }

                field(itemCategoryCode; Rec."Item Category Code")
                {
                    Caption = 'Item Category Code';
                }
                field(remark; Rec.Remark)
                {
                    Caption = 'Remark';
                }
                field(serialNo; Rec."Serial No.")
                {
                    Caption = 'serialNo';
                }



            }
        }
    }
}
