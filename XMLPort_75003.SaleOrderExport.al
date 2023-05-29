xmlport 75003 SaleOrderExport
{
    Caption = 'SaleOrderExport';
    Format = VariableText;
    Direction = Import;
    TextEncoding = UTF8;
    UseRequestPage = false;
    TableSeparator = '';

    schema
    {
        textelement(RootNodeName)
        {
            tableelement(SaleOrderExport; SaleOrderExport)
            {
                fieldelement(DocumentNo; SaleOrderExport."Document No.")
                {
                }
                fieldelement(CustomerNo; SaleOrderExport."Customer No.")
                {
                }
                fieldelement(ItemNo; SaleOrderExport."Item No.")
                {
                }
                fieldelement(S_75; SaleOrderExport.S_75)
                {
                }
                fieldelement(S_80S; SaleOrderExport.S_80S)
                {
                }
                fieldelement(S_85M; SaleOrderExport.S_85M)
                {
                }
                fieldelement(S_90L; SaleOrderExport.S_90L)
                {
                }
                fieldelement(S_95XL; SaleOrderExport.S_95XL)
                {
                }
                fieldelement(S_1002XL; SaleOrderExport.S_1002XL)
                {
                }
                fieldelement(S_1053XL; SaleOrderExport.S_1053XL)
                {
                }
                fieldelement(S_1104XL; SaleOrderExport.S_1104XL)
                {
                }
                fieldelement(S_1155XL; SaleOrderExport.S_1155XL)
                {
                }
                
                fieldelement(SelectOrderType; SaleOrderExport."Select Order Type")
                {
                }
                fieldelement(Remark; SaleOrderExport.Remark)
                {
                }
                fieldelement(ItemCategoryCide;SaleOrderExport."Item Category Code")
                {
                    
                }
                fieldelement(Status; SaleOrderExport.Status)
                {
                }
                fieldelement(OrderType; SaleOrderExport."Order Type")
                {
                }
            }
        }
    }
    requestpage
    {
        layout
        {
            area(content)
            {
                group(GroupName)
                {
                }
            }
        }
        actions
        {
            area(processing)
            {
            }
        }
    }
}
