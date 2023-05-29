xmlport 75002 "Customer Order Type"
{
    Caption = 'Customer Order Type';
    Format = VariableText;
    Direction = Import;
    TextEncoding = UTF8;
    UseRequestPage = false;
    TableSeparator = '';
    schema
    {
        textelement(RootNodeName)
        {
            tableelement(CustomerOrderType; "Customer Order Type")
            {
                fieldelement(SellToCustomerNo; CustomerOrderType."Sell To Customer No.")
                {
                }
                fieldelement(BillToCustomerNo; CustomerOrderType."Bill To Customer No.")
                {
                }
                fieldelement(OrderType; CustomerOrderType."Order Type")
                {
                }
                fieldelement(UOM; CustomerOrderType.UOM)
                {
                }
                fieldelement(Remarks; CustomerOrderType.Remarks)
                {
                }
                fieldelement(ActiveYesNo; CustomerOrderType."Active Yes/No")
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
