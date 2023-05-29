xmlport 75000 "Item Master App"
{
    Caption = 'ItemMasterApp';
    Format = VariableText;
    Direction = Import;
    TextEncoding = UTF8;
    UseRequestPage = false;
    TableSeparator = '';

    schema
    {
        textelement(RootNodeName)
        {
            tableelement("ItemMasterApp"; "Item Master App")
            {
                fieldelement(ItemNo;ItemMasterApp."Item No.")
                {

                }
                fieldelement(Name; ItemMasterApp."Name")
                {
                }
                fieldelement(ItemSize;ItemMasterApp."Item Size")
                {
                }
                fieldelement(Remark;ItemMasterApp.Remark)
                {
                }
                fieldelement(catagoryCode;ItemMasterApp."Catagory Code")
                {

                }  
                Fieldelement(ImageURL;ItemMasterApp."Image URL")
                {
                    
                }
            }
        }
    }

}