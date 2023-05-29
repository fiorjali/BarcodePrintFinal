codeunit 75000 PrintBarcodeITExpert
{
    var
        //50019 Barcode Serial No.
        UID: Text[50];
        LotDetails: Record "Lot Details";
        ItemRec: Record "Item";
        UOMRec: Record "Unit of Measure";
        ItemUOMRec: Record "Item Unit of Measure";
        ItemVariantRec: Record "Item Variant";
        LoginsRec: Record "User";
        TodaylastBarcode: Code[250];
        NewSnoToPrint: Code[250];
        NewEntryNo: Integer;
        BSnoPrintRec: Record "Barcode Serial No.";
        UserSetupRec: Record "User Setup";
        LocationRec: Record "Location";
        BSnoRec: Record "Barcode Serial No.";
        DAYNO: Text[30];
        MONTHNO: Text[30];
        PONo: Code[20];
        i: Integer;
        InventorySetupRec: Record "Inventory Setup";
        SalesPriceRec: Record "Sales Price";
        //SalesPriceRec: Record "Price List line";
        PriceGroupCodeG: Code[20];
        FirstSno: Code[100];
        LastSno: Code[100];
        VariantCodeG: Code[20];
        ItemNoG: Code[20];
        UOMG: Code[20];
        UOM: Code[20];
        MRPTextG: Text[50];
        UOMMRPG: Boolean;
        Barcode: Text[20];

    procedure CredentialsValidate(inputJson: Text): Text[1024]
    var
        UserID: Text[20];
        UserPassword: Text[20];
        Orderjson: JsonObject;
        Myresult: Text[1024];
        jsontext: Text[1024];
        input: JsonObject;
        c: JsonToken;
        SaleLineRec: Record "Sales Line";


    begin

        input.ReadFrom(inputJson);
        //Get user ID
        if input.Get('UserID', c) then begin
            UserID := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'UserID Node not found in Payload');
            exit(Myresult);
        end;

        //Get UserPassword
        if input.Get('UserPassword', c) then begin
            UserPassword := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'UserPassword Node not found in Payload');
            exit(Myresult);
        end;
        //SaleLineRec.BarcodePacking()
        //SaleLineRec.Barco

        if UserSetupRec.Get(UserID) then begin
            if (UserPassword.ToUpper() = UserSetupRec.Password) then begin
                Myresult := 'User Login Successfully';
                jsontext := CreateJsonPayload('1', 'True', Myresult);
                jsontext := jsontext.Replace('\', '');
                exit(jsontext);
            end else begin
                Myresult := 'Invalid Password';
                jsontext := CreateJsonPayload('0', 'False', Myresult);
                jsontext := jsontext.Replace('\', '');
                exit(jsontext);
            end;
        end else begin
            Myresult := 'User not found in User Setup';
            jsontext := CreateJsonPayload('0', 'False', Myresult);
            jsontext := jsontext.Replace('\', '');
            exit(jsontext);
        end;
    end;

    procedure BarcodePrint(inputJson: Text): Text[1024]
    var
        jsontext: Text[1024];
        Orderjson: JsonObject;
        input: JsonObject;
        c: JsonToken;
        Myresult: Text;
        FunctionResult: Text[1024];


        //Function Parameter Var
        PhyLotNo: Text[20];
        ItemNo: Code[20];
        VariantCode: Code[20];
        PrintReport: Code[20];
        UOM: Code[20];
        IssuedToUID: Code[100];
        No0fBarcodes: Integer;
        UOMMRP: Boolean;
        PriceGroupCode: Text[50];
        PurStndrdQty: Decimal;
        CreatedBy: Code[30];
        ErrTxt: Text[1024];
        StartNo: Code[20];
        EndNo: Code[20];

    begin
        input.ReadFrom(inputJson);
        FunctionResult := 'False';
        FunctionResult := ValidateNodeName_BarcodePrint(inputJson);
        //FunctionResult := 'True';
        if (FunctionResult = 'True') then begin

            //Get All Parameter
            if input.Get('PhyLotNo', c) then begin
                PhyLotNo := c.AsValue().AsText();
            end;
            if input.Get('ItemNo', c) then begin
                ItemNo := c.AsValue().AsText();
                if ItemNo = '~' then
                    ItemNo := ''
            end;
            if input.Get('VariantCode', c) then begin
                VariantCode := c.AsValue().AsText();
                if VariantCode = '~' then
                    VariantCode := '';
            end;
            if input.Get('PrintReport', c) then begin
                PrintReport := c.AsValue().AsText();
            end;
            if input.Get('UOM', c) then begin
                UOM := c.AsValue().AsText();
            end;
            if input.Get('IssuedToUID', c) then begin
                IssuedToUID := c.AsValue().AsText();
            end;
            if input.Get('No0fBarcodes', c) then begin
                No0fBarcodes := c.AsValue().AsInteger();
            end;
            if input.Get('UOMMRP', c) then begin
                UOMMRP := c.AsValue().AsBoolean();
            end;
            if input.Get('PriceGroupCode', c) then begin
                PriceGroupCode := c.AsValue().AsText();
                if PriceGroupCode = '~' then
                    PriceGroupCode := '';
            end;
            if input.Get('PurStndrdQty', c) then begin
                PurStndrdQty := c.AsValue().AsDecimal();
            end;
            if input.Get('CreatedBy', c) then begin
                CreatedBy := c.AsValue().AsText();
            end;

            /*
            if input.Get('ErrTxt', c) then begin
                ErrTxt := c.AsValue().AsText();
            end;
            if input.Get('StartNo', c) then begin
                StartNo := c.AsValue().AsText();
            end;
            if input.Get('EndNo', c) then begin
                EndNo := c.AsValue().AsText();
            end;
            */

            //Function logic
            IF PhyLotNo = '' THEN BEGIN
                ErrTxt := 'Please specify Phy. Lot No.';
                jsontext := CreateJsonPayload('0', 'False', ErrTxt);
                exit(jsontext);
            END;

            IF PrintReport = '2' THEN BEGIN
                IF NOT (UOM = 'BOX') THEN BEGIN
                    ErrTxt := 'Wrong selection of UOM';
                    jsontext := CreateJsonPayload('0', 'False', ErrTxt);
                    exit(jsontext);
                END;
            END;

            IF NOT (PrintReport = 'PURCHASE') THEN BEGIN   //FC Nida 21082014
                IF NOT (PhyLotNo = 'NA') THEN
                    IF NOT (PhyLotNo = 'SNA') THEN
                        IF NOT (PhyLotNo = 'CNA') THEN
                            IF NOT LotDetails.GET(PhyLotNo) THEN BEGIN
                                LotDetails.INIT;
                                LotDetails."Lot No." := PhyLotNo;
                                LotDetails."Item No." := ItemNo;
                                LotDetails.INSERT(TRUE);
                            END ELSE BEGIN
                                IF NOT (LotDetails."Item No." = ItemNo) THEN BEGIN
                                    ErrTxt := 'Lot No ' + PhyLotNo + ' Already use in ' + LotDetails."Item No.";
                                    jsontext := CreateJsonPayload('0', 'False', ErrTxt);
                                    exit(jsontext);
                                END;
                            END;

            END;
            //Assign Local Var to Gobal Var
            PriceGroupCodeG := PriceGroupCode;
            ItemNoG := ItemNo;
            VariantCodeG := VariantCode;
            UOMG := UOM;
            UOMMRPG := UOMMRP;
            //Mukesh 050916
            //UID :=IssuedToUID;
            UID := CreatedBy;
            IssuedToUID := CreatedBy;
            //Assign Local Var to Gobal Var

            ItemRec.RESET;
            UOMRec.RESET;
            ItemUOMRec.RESET;
            ItemVariantRec.RESET;

            IF ItemRec.GET(ItemNo) THEN;
            IF UOMRec.GET(UOM) THEN;
            IF ItemUOMRec.GET(ItemNo, UOM) THEN;
            IF ItemVariantRec.GET(ItemNo, VariantCode) THEN;

            if InventorySetupRec.GET() Then;
            if InventorySetupRec."PCS UOM" = '' then begin
                ErrTxt := 'PCS UOM is blank in Inventory Setup Table';
                jsontext := CreateJsonPayload('0', 'False', ErrTxt);
                exit(jsontext);
            end;


            TodaylastBarcode := '';

            //Mukesh 050916
            //UserSetupRec.GET(USERID);
            if not UserSetupRec.GET(CreatedBy) then begin
                ErrTxt := CreatedBy + ' Not found in User Master Master';
                jsontext := CreateJsonPayload('0', 'False', ErrTxt);
                exit(jsontext);
            end;
            //UserSetupRec.GET(IssuedToUID);
            if UserSetupRec."User Location" = '' then begin
                ErrTxt := UserSetupRec."User Location" + ' is blank User Setup Master';
                jsontext := CreateJsonPayload('0', 'False', ErrTxt);
                exit(jsontext);
            end;

            if not LocationRec.GET(UserSetupRec."User Location") then begin
                ErrTxt := UserSetupRec."User Location" + ' Not found in Location Master';
                jsontext := CreateJsonPayload('0', 'False', ErrTxt);
                exit(jsontext);
            end;




            BSnoRec.RESET;
            IF STRLEN(FORMAT(DATE2DMY(TODAY, 1))) = 1 THEN
                DAYNO := '0' + FORMAT(DATE2DMY(TODAY, 1))
            ELSE
                DAYNO := FORMAT(DATE2DMY(TODAY, 1));

            IF STRLEN(FORMAT(DATE2DMY(TODAY, 2))) = 1 THEN
                MONTHNO := '0' + FORMAT(DATE2DMY(TODAY, 2))
            ELSE
                MONTHNO := FORMAT(DATE2DMY(TODAY, 2));

            BSnoRec.SETFILTER(BSnoRec."Serial No.", '%1', DAYNO + MONTHNO +
            COPYSTR(FORMAT(DATE2DMY(TODAY, 3)), 3, 2) + LocationRec."Location ID" + '*');

            IF BSnoRec.FINDLAST THEN
                TodaylastBarcode := BSnoRec."Serial No."
            ELSE
                TodaylastBarcode := '';



            NewSnoToPrint := GetNextSerialNo(TodaylastBarcode);

            /*ErrTxt := 'Test5-' + NewSnoToPrint;
            jsontext := CreateJsonPayload('0', 'False', ErrTxt);
            exit(jsontext);
            */
            FOR i := 1 TO No0fBarcodes DO BEGIN
                CLEAR(BSnoRec);
                BSnoRec.INIT;
                //FC 110616 +
                BSnoRec."Serial No." := NewSnoToPrint;
                //FC 110616 -
                BSnoRec.Status := BSnoRec.Status::Printed;
                BSnoRec."Item Code" := ItemNo;
                BSnoRec."Item Description" := ItemRec.Description;
                BSnoRec."Variant Code" := VariantCode;
                BSnoRec."Unit of Measure Code" := UOM;
                //FC BSnoRec."Product Group Code" := ItemRec."Product Group Code";
                BSnoRec."Item Category Code" := ItemRec."Item Category Code";
                BSnoRec."Creation Date" := TODAY;
                BSnoRec.CreatedBy := CreatedBy;
                UserSetupRec.GET(IssuedToUID);


                InventorySetupRec.GET;

                SalesPriceRec.RESET;
                SalesPriceRec.SETRANGE("Item No.", ItemNo);
                SalesPriceRec.SETRANGE("Sales Type", SalesPriceRec."Sales Type"::"Customer Price Group");
                SalesPriceRec.SETRANGE("Sales Code", PriceGroupCode);
                SalesPriceRec.SETRANGE("Variant Code", VariantCode);
                SalesPriceRec.SETRANGE("Unit of Measure Code", InventorySetupRec."PCS UOM");
                IF SalesPriceRec.FINDLAST THEN BEGIN
                    IF (SalesPriceRec."MRP Price" = 0) OR (SalesPriceRec."Unit Price" = 0) THEN BEGIN
                        ErrTxt := 'MRP Price/Unit Price is Zero in Sales Price For Item ' + ItemNo + ' ,Variant ' + VariantCode + ' ,Price Group ' + PriceGroupCode + ' And Unit of Measure Code ' + InventorySetupRec."PCS UOM";
                        jsontext := CreateJsonPayload('0', 'False', ErrTxt);
                        exit(jsontext);
                    END;
                    BSnoRec.MRP := SalesPriceRec."MRP Price";
                    BSnoRec.WSP := SalesPriceRec."Unit Price";
                    //ErrTxt := Format(SalesPriceRec."MRP Price");
                    //jsontext := CreateJsonPayload('0', 'False', ErrTxt);
                    //exit(jsontext);
                END;

                //ErrTxt := SalesPriceRec.GetFilters + '-' + Format(SalesPriceRec."MRP Price");
                //jsontext := CreateJsonPayload('0', 'False', ErrTxt);
                //exit(jsontext);

                BSnoRec.MRP := SalesPriceRec."MRP Price";
                BSnoRec.WSP := SalesPriceRec."Unit Price";

                SalesPriceRec.RESET;
                SalesPriceRec.SETRANGE("Item No.", ItemNo);
                SalesPriceRec.SETRANGE("Sales Type", SalesPriceRec."Sales Type"::"Customer Price Group");
                SalesPriceRec.SETRANGE("Sales Code", PriceGroupCode);
                SalesPriceRec.SETRANGE("Variant Code", VariantCode);
                SalesPriceRec.SETRANGE("Unit of Measure Code", BSnoRec."Unit of Measure Code");
                IF SalesPriceRec.FINDLAST THEN BEGIN
                    IF (SalesPriceRec."MRP Price" = 0) THEN BEGIN
                        ErrTxt := 'MRP Price is Zero in Sales Price For Item ' + ItemNo + ' ,Variant ' + VariantCode + ' ,Price Group ' + PriceGroupCode + ' And Unit of Measure Code ' + BSnoRec."Unit of Measure Code";
                        jsontext := CreateJsonPayload('0', 'False', ErrTxt);
                        exit(jsontext);
                    END;
                    BSnoRec."MRP UOM" := SalesPriceRec."MRP Price";
                END;

                BSnoRec."MRP UOM" := SalesPriceRec."MRP Price";
                BSnoRec."MRP for UOM" := UOMMRP;
                //BSnoRec."Current Location" := UserSetupRec."User Location";
                BSnoRec."Base Unit of Measure" := ItemRec."Base Unit of Measure";
                BSnoRec."Quantity Per" := ItemUOMRec."Qty. per Unit of Measure";


                IF PrintReport = 'PURCHASE' THEN BEGIN
                    BSnoRec.Quantity := PurStndrdQty;
                    BSnoRec."Quantity (Base)" := PurStndrdQty;
                END ELSE BEGIN
                    BSnoRec.Quantity := 1;
                    BSnoRec."Quantity (Base)" := ItemUOMRec."Qty. per Unit of Measure" * BSnoRec.Quantity;
                END;


                BSnoRec."Phy. Lot No." := PhyLotNo;

                IF (ItemRec."Gen. Prod. Posting Group" <> 'RM') AND (ItemRec."Gen. Prod. Posting Group" <> 'PKG') THEN
                    IF BSnoRec."Item Code" <> '' THEN
                        BSnoRec."Product Barcode" :=
                        PADSTR(BSnoRec."Item Code", 8, '0') +
                        PADSTR(BSnoRec."Variant Code", 3, '0') +
                        //PADSTR(FORMAT(ItemRec.QtyinPCS(BSnoRec."Item Code", BSnoRec."Unit of Measure Code", 1)), 2, '0');
                        PADSTR(FORMAT(QtyinPCS(BSnoRec."Item Code", BSnoRec."Unit of Measure Code", 1)), 2, '0');
                //{
                //CLEAR(CreateBarcode);
                //CREATE(CreateBarcode,FALSE,TRUE);
                //Barcode := BSnoRec."Product Barcode";
                //Barcode := CreateBarcode.Code128(Barcode);
                //BSnoRec."Artical Barcode" := Barcode;
                //}

                //ErrTxt := 'Test6';
                //jsontext := CreateJsonPayload('0', 'False', ErrTxt);
                //exit(jsontext);
                

                BSnoRec.INSERT(TRUE);
                COMMIT;
                //ErrTxt := 'Test7';
                //jsontext := CreateJsonPayload('0', 'False', ErrTxt);
                //exit(jsontext);

                UserSetupRec.GET(IssuedToUID);
                NewEntryNo := NewEntryNo + 1;
                NewSnoToPrint := GetNextSerialNo(NewSnoToPrint);
                IF i = 1 THEN
                    FirstSno := BSnoRec."Serial No.";
                IF i = No0fBarcodes THEN
                    LastSno := BSnoRec."Serial No.";
            END;
            //BSnoPrintRec.RESET;
            //BSnoPrintRec.SETRANGE(BSnoPrintRec."Serial No.",FirstSno,LastSno);
            //IF UOMRec.GET(BSnoRec."Unit of Measure Code") THEN;

            StartNo := FirstSno;
            EndNo := LastSno;
            ErrTxt := '';
            Orderjson.Add('id', '1');
            Orderjson.Add('Success', 'True');
            Orderjson.Add('StartNo', StartNo);
            Orderjson.Add('EndNo', EndNo);
            Orderjson.Add('ErrTxt', ErrTxt);
            Orderjson.WriteTo(jsontext);
            jsontext := jsontext.Replace('\', '');
            exit(jsontext);
        end else begin
            jsontext := CreateJsonPayload('1', 'False', 'Invalid Jason Payload');
            jsontext := jsontext.Replace('\', '');
            exit(jsontext);
        end;
    end;


    procedure CreateJsonPayload(id: Text; Success: Text; Message: Text): Text[1024]
    var
        Orderjson: JsonObject;
        jsontext: Text[1024];
    begin
        Orderjson.Add('id', id);
        Orderjson.Add('Success', Success);
        Orderjson.Add('Message', Message);
        Orderjson.WriteTo(jsontext);
        jsontext := jsontext.Replace('\', '');
        exit(jsontext);
    end;

    procedure ValidateNodeName_BarcodePrint(PaylodText: Text[1024]): Text[1024]
    var
        input: JsonObject;
        PhyLotNo: Text[1024];
        ItemNo: Text[20];
        VariantCode: Text[20];
        c: JsonToken;
        Myresult: Text[1024];
        PrintReport: Text[20];
        UOM: Code[20];
        IssuedToUID: Text[100];
        No0fBarcodes: Integer;
        UOMMRP: Boolean;
        PriceGroupCode: Text[50];
        PurStndrdQty: Decimal;
        CreatedBy: Text[30];
        ErrTxt: Text[1024];
        StartNo: Code[20];
        EndNo: Code[20];


    begin
        input.ReadFrom(PaylodText);

        //Get PhyLotNo
        if not input.Get('PhyLotNo', c) then begin
            Myresult := CreateJsonPayload('0', 'False', 'PhyLotNo Node not found in Payload');
            exit(Myresult);
        end;

        //Get ItemNo
        if not input.Get('ItemNo', c) then begin
            Myresult := CreateJsonPayload('0', 'False', 'ItemNo Node not found in Payload');
            exit(Myresult);
        end;
        //Get VariantCode
        if not input.Get('VariantCode', c) then begin
            Myresult := CreateJsonPayload('0', 'False', 'VariantCode Node not found in Payload');
            exit(Myresult);
        end;

        //Get PrintReport
        if not input.Get('PrintReport', c) then begin
            Myresult := CreateJsonPayload('0', 'False', 'PrintReport Node not found in Payload');
            exit(Myresult);
        end;

        //Get UOM
        if not input.Get('UOM', c) then begin
            Myresult := CreateJsonPayload('0', 'False', 'UOM Node not found in Payload');
            exit(Myresult);
        end;

        //Get IssuedToUID
        if not input.Get('IssuedToUID', c) then begin
            Myresult := CreateJsonPayload('0', 'False', 'IssuedToUID Node not found in Payload');
            exit(Myresult);
        end;

        //Get No0fBarcodes
        if not input.Get('No0fBarcodes', c) then begin
            Myresult := CreateJsonPayload('0', 'False', 'No0fBarcodes Node not found in Payload');
            exit(Myresult);
        end;

        //Get UOMMRP
        if not input.Get('UOMMRP', c) then begin
            Myresult := CreateJsonPayload('0', 'False', 'UOMMRP Node not found in Payload');
            exit(Myresult);
        end;

        //Get PriceGroupCode
        if not input.Get('PriceGroupCode', c) then begin
            Myresult := CreateJsonPayload('0', 'False', 'PriceGroupCode Node not found in Payload');
            exit(Myresult);
        end;

        //Get PurStndrdQty
        if not input.Get('PurStndrdQty', c) then begin
            Myresult := CreateJsonPayload('0', 'False', 'PurStndrdQty Node not found in Payload');
            exit(Myresult);
        end;
        //Get CreatedBy
        if not input.Get('CreatedBy', c) then begin
            Myresult := CreateJsonPayload('0', 'False', 'CreatedBy Node not found in Payload');
            exit(Myresult);
        end;

        /*        //Get ErrTxt
        if not input.Get('ErrTxt', c) then begin
            Myresult := CreateJsonPayload('0', 'False', 'ErrTxt Node not found in Payload');
            exit(Myresult);
        end;

        //Get StartNo
        if not input.Get('StartNo', c) then begin
            Myresult := CreateJsonPayload('0', 'False', 'StartNo Node not found in Payload');
            exit(Myresult);
        end;

        //Get EndNo
        if not input.Get('EndNo', c) then begin
            Myresult := CreateJsonPayload('0', 'False', 'EndNo Node not found in Payload');
            exit(Myresult);
        end; */

        Myresult := 'True';
        exit(Myresult);


    end;


    PROCEDURE GetNextSerialNo(LastSNO: Code[250]) NewSno: Code[250];
    VAR
        DDMMYYvar: Integer;
        DDMMYYToday: Code[6];
        LocationRec: Record "Location";
    Begin
        IF LastSNO <> '' THEN
            EVALUATE(DDMMYYvar, COPYSTR(LastSNO, 1, 6));
        IF DATE2DMY(TODAY, 1) < 10 THEN
            DDMMYYToday := '0' + FORMAT(DATE2DMY(TODAY, 1))
        ELSE
            DDMMYYToday := FORMAT(DATE2DMY(TODAY, 1));
        IF DATE2DMY(TODAY, 2) < 10 THEN
            DDMMYYToday := DDMMYYToday + '0' + FORMAT(DATE2DMY(TODAY, 2))
        ELSE
            DDMMYYToday := DDMMYYToday + FORMAT(DATE2DMY(TODAY, 2));

        DDMMYYToday := DDMMYYToday + COPYSTR(FORMAT(DATE2DMY(TODAY, 3)), 3, 2);

        IF (LastSNO = '') THEN BEGIN
            //UserSetupRec.GET(UserId);
            LocationRec.GET(UserSetupRec."User Location");
            //NewSno := DDMMYYToday + LocationRec."Location ID" + '00001';
            NewSno := DDMMYYToday + LocationRec."Location ID" + '000001';
        END ELSE BEGIN
            NewSno := INCSTR(LastSNO);
        END;
        UpdateMRPText(MRPTextG);

    END;

    PROCEDURE UpdateMRPText(VAR MRPText: Text[50])
    var

        InventorySetupRec: Record "Inventory Setup";
        SalesPriceRec: Record "Sales Price";
        ItemNoG: Code[20];

    BEGIN
        MRPText := '';
        InventorySetupRec.GET;
        SalesPriceRec.RESET;
        SalesPriceRec.SETRANGE(SalesPriceRec."Item No.", ItemNoG);
        SalesPriceRec.SETRANGE(SalesPriceRec."Sales Type", SalesPriceRec."Sales Type"::"Customer Price Group");
        SalesPriceRec.SETRANGE(SalesPriceRec."Sales Code", PriceGroupCodeG);
        SalesPriceRec.SETRANGE(SalesPriceRec."Variant Code", VariantCodeG);
        IF UOMMRPG THEN
            SalesPriceRec.SETRANGE(SalesPriceRec."Unit of Measure Code", UOM)
        ELSE
            SalesPriceRec.SETRANGE(SalesPriceRec."Unit of Measure Code", InventorySetupRec."PCS UOM");

        IF SalesPriceRec.FINDLAST THEN BEGIN
            MRPText := FORMAT(SalesPriceRec."MRP Price");
        END;

    END;


    procedure QtyinPCS(ItemCode: Code[20]; UOM: Code[20]; QtySupplied: Decimal): Decimal
    var
        InventorySetupRec: Record "Inventory Setup";
        IUOMS: Record "Item Unit of Measure";
        IUOMO: Record "Item Unit of Measure";
    begin
        InventorySetupRec.GET;
        IUOMS.GET(ItemCode, UOM);
        IUOMO.GET(ItemCode, InventorySetupRec."PCS UOM");
        EXIT(QtySupplied * IUOMS."Qty. per Unit of Measure" / IUOMO."Qty. per Unit of Measure");
    end;



}