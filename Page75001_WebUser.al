
page 75001 "Web User"
{
    ApplicationArea = All;
    Caption = 'Web User';
    PageType = List;
    SourceTable = "Web User";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("User Id "; Rec."User Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the User Id  field.';
                }
                field(Password; Rec.Password)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Password field.';
                }
                field("User Name"; Rec."User Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the User Name field.';
                }
                field("Active "; Rec."Active Yes/No")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Active  field.';
                }
                field("Sell To Customer No."; Rec."Sales To Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sell To Customer No. field.';
                }
                field("Login Type"; Rec."Login Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Login Type field.';
                }

                field("Sell To customer Name"; Rec."Sell To customer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sell To customer Name field.';
                }
            }
        }
    }

    actions
    {
        area("Processing")
        {
            action(XmlIMport)
            {
                ApplicationArea = all;
                Caption = 'Xml Import';
                Image = Import;
                Promoted =true;
                PromotedCategory =Process;
                trigger onAction()
                var

                begin

                    Xmlport.Run(75001,false,true);

                end;

            }
            action(ShowTotalCount)
            {
                ApplicationArea = all;
                Caption = 'Show Total Count';
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                trigger onAction()
                var

                begin

                   Message('Total Record(s)  %1 ',Rec.Count);

                end;
            }
        }
    }


}

