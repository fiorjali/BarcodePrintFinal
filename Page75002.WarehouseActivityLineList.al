page 75002 "Warehouse Activity Line List"
{

    ApplicationArea = All;
    Caption = 'Warehouse Activity Line List';
    PageType = List;
    SourceTable = "Warehouse Activity Line";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Action Type"; Rec."Action Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the action type for the warehouse activity line.';
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the warehouse activity line.';
                }
                field("Source Type"; Rec."Source Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of source document to which the warehouse activity line relates, such as sales, purchase, and production.';
                }
                field("Source Subtype"; Rec."Source Subtype")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the source subtype of the document related to the warehouse request.';
                }
                field("Source No."; Rec."Source No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the source document that the entry originates from.';
                }
                field("Source Line No."; Rec."Source Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the line number of the source document that the entry originates from.';
                }
                field("Source Subline No."; Rec."Source Subline No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the source subline number.';
                }
                field("Source Document"; Rec."Source Document")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of document that the line relates to.';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code for the location where the activity occurs.';
                }
                field("Shelf No."; Rec."Shelf No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the shelf number of the item for informational use.';
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the item number of the item to be handled, such as picked or put away.';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the variant of the item on the line.';
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies how each unit of the item or resource is measured, such as in pieces or hours. By default, the value in the Base Unit of Measure field on the item or resource card is inserted.';
                }
                field("Qty. per Unit of Measure"; Rec."Qty. per Unit of Measure")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the quantity per unit of measure of the item on the line.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a description of the item on the line.';
                }
                field("Description 2"; Rec."Description 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a description of the item on the line.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the quantity of the item to be handled, such as received, put-away, or assigned.';
                }
                field("Qty. (Base)"; Rec."Qty. (Base)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the quantity of the item to be handled, in the base unit of measure.';
                }
                field("Qty. Outstanding"; Rec."Qty. Outstanding")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of items that have not yet been handled for this warehouse activity line.';
                }
                field("Qty. Outstanding (Base)"; Rec."Qty. Outstanding (Base)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of items, expressed in the base unit of measure, that have not yet been handled for this warehouse activity line.';
                }
                field("Qty. Handled"; Rec."Qty. Handled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of items on the line that have been handled in this warehouse activity.';
                }
                field("Qty. to Handle (Base)"; Rec."Qty. to Handle (Base)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the quantity of items to be handled in this warehouse activity.';
                }
                field("Qty. to Handle"; Rec."Qty. to Handle")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies how many units to handle in this warehouse activity.';
                }
                field("Shipping Advice"; Rec."Shipping Advice")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the shipping advice, informing whether partial deliveries are acceptable, copied from the source document header.';
                }
                field("Due Date"; Rec."Due Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date when the warehouse activity must be completed.';
                }
                field("Destination Type"; Rec."Destination Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies information about the type of destination, such as customer or vendor, associated with the warehouse activity line.';
                }
                field("Destination No."; Rec."Destination No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number or code of the customer, vendor or location related to the activity line.';
                }
                field("Shipping Agent Code"; Rec."Shipping Agent Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code for the shipping agent who is transporting the items.';
                }
                field("Shipping Agent Service Code"; Rec."Shipping Agent Service Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code for the service, such as a one-day delivery, that is offered by the shipping agent.';
                }
                field("Shipment Method Code"; Rec."Shipment Method Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the delivery conditions of the related shipment, such as free on board (FOB).';
                }
                field("Starting Date"; Rec."Starting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Starting Date field.';
                }
                field("Serial No."; Rec."Serial No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the serial number to handle in the document.';
                }
                field("Lot No."; Rec."Lot No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the lot number to handle in the document.';
                }
                field("Warranty Date"; Rec."Warranty Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Warranty Date field.';
                }
                field("Expiration Date"; Rec."Expiration Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the expiration date of the serial/lot numbers if you are putting items away.';
                }
                field("Bin Code"; Rec."Bin Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the bin where the items are picked or put away.';
                }
                field("Zone Code"; Rec."Zone Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the zone code where the bin on this line is located.';
                }
                field("Activity Type"; Rec."Activity Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of warehouse activity for the line.';
                }
                field("Whse. Document Type"; Rec."Whse. Document Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of warehouse document from which the line originated.';
                }
                field("Whse. Document No."; Rec."Whse. Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the warehouse document that is the basis for the action on the line.';
                }
                field("Whse. Document Line No."; Rec."Whse. Document Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the line in the warehouse document that is the basis for the action on the line.';
                }
                field("Bin Ranking"; Rec."Bin Ranking")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bin Ranking field.';
                }
                field(Cubage; Rec.Cubage)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total cubage of items on the line, calculated based on the Quantity field.';
                }
                field(Weight; Rec.Weight)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the weight of one item unit when measured in the specified unit of measure.';
                }
                field("Bin Type Code"; Rec."Bin Type Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bin Type Code field.';
                }
                field("Breakbulk No."; Rec."Breakbulk No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Breakbulk No. field.';
                }
                field("Original Breakbulk"; Rec."Original Breakbulk")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Original Breakbulk field.';
                }
                field(Breakbulk; Rec.Breakbulk)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Breakbulk field.';
                }
                field("Cross-Dock Information"; Rec."Cross-Dock Information")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies an option for specific information regarding the cross-dock activity.';
                }
                field("Carton Packed By"; Rec."Carton Packed By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Carton Packed By field.';
                }
                field(ItemBarcode; Rec.ItemBarcode)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the ItemBarcode field.';
                }
                field("Base Unit of Measure"; Rec."Base Unit of Measure")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Base Unit of Measure field.';
                }
                field("Assemble to Order"; Rec."Assemble to Order")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies that the inventory pick line is for assembly items that are assembled to a sales order before being shipped.';
                }
                field(Dedicated; Rec.Dedicated)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Dedicated field.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
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

                    Message('Total Record(s)  %1 ', Rec.Count);

                end;
            }
        }
    }
}
