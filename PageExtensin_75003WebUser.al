/* pageextension 75003 WebUser extends "Web USer"

{
   

    actions
    {
        addlast("Processing")
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
        }
    }

} */