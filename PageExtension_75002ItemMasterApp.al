// pageextension 75002 XMItemMasterAp extends "Item Master App"

// {
   

//     actions
//     {
//         addlast("Processing")
//         {
//             action(XmlIMport)
//             {
//                 ApplicationArea = all;
//                 Caption = 'Item Master Import';
//                 Image = Import;
//                 Promoted =true;
//                 PromotedCategory =Process;
//                 trigger onAction()
//                 var

//                 begin

//                     Xmlport.Run(75001,false,true);

//                 end;

//             }
//         }
//     }

// }