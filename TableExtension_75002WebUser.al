tableextension 75002 WebUserExt extends "Web User"
{

    fields
    {
        field(7; "Sales To Customer No."; Code[20])
        {
            Caption = 'Sales To Customer No.';
            DataClassification = ToBeClassified;
            TableRelation = Customer;
            //CaptionML=[ENU=Sales-to Customer No.];
        }

        field(8; "Login Type"; Option)
        {
            Caption = 'Login Type';
            DataClassification = ToBeClassified;
            //OptionCaptionML = ENU='Distributor','ASM/RSM';
            OptionMembers = "Distributor","ASM/RSM";
        }

        field(9; "Sell To customer Name"; Text[100])
        {
            Caption = 'Sell To customer Name';
            DataClassification = ToBeClassified;
        }
    }
}