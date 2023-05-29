xmlport 75001 "Web USer"
{
    Caption = 'Web User';
    Format = VariableText;
    Direction = Import;
    TextEncoding = UTF8;
    UseRequestPage = false;
    TableSeparator = '';

    schema
    {
        textelement(RootNodeName)
        {
            tableelement("WebUser"; "Web User")
            {
                fieldelement(UserID;WebUser."USer ID")
                {

                }
                fieldelement(Password; WebUser."Password")
                {
                }
                fieldelement(USerName;WebUser."User Name")
                {
                }
                fieldelement(Active;WebUser."Active Yes/No")
                {
                }
                fieldelement("SalesToCustomerNo.";WebUser."Sales To Customer No.")
                {

                }  
                Fieldelement(LoginType;WebUser."Login Type")
                {
                    
                }
                fieldelement(SellTocustomerName;WebUser."Sell To customer Name")
                {

                }
            }
        }
    }

}