codeunit 75001 ProcessBarcodeITExpert
{

    var
        PickLstRec: Record "Standard Text";
        SalesLineRec: Record "Sales Header";
        BSNO: Record "Barcode Serial No.";
        BMERec: Record "Barcode Movement Entry";
        BMERec2: Record "Barcode Movement Entry";
        NewEntryNo: Integer;
        UserCode: Code[20];
        BlanketOrderNo: Code[100];
        WarehouseLineRec: Record "Warehouse Activity Line";
        WarehouseHeaderRec: Record "Warehouse Activity Header";
        SalesHeaderRec: Record "Sales Header";
        CurrBarcode: Code[250];
        UserSetup: Record "User Setup";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Item: Record Item;
        UOMmgt: Codeunit "Unit of Measure Management";
        LastEntryNo: Integer;
        BarcodeQty: Decimal;
        SelectedBufferQty: Decimal;
        BarcodeProcessBuffer: Record "Barcode Processing Buffer"; //need to check [ayush]
        ManuSetupRec: Record "Manufacturing Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        ItemJournalLine: Record "Item Journal Line";
        ParentBSNORec: Record "Barcode Serial No.";
        Bin: Record Bin;
        BSnoCode: Code[100];
        ActiveSession: Record "Active Session";
        SerialNoOrder: Integer;
        BarCodeSrno: Record "Barcode Serial No.";
        ProdOrdLineRec: Record "Prod. Order Line";
        ProdOrderLineRec: Record "Prod. Order Line";
        RecSL: Record "Sales Line";
        CustomerPriceGroupCode: Code[20];
        PurchLineRec: Record "Purchase Line";
        TransferHdr: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        TransferLine1: Record "Transfer Line";
        BarCodeSrnoST: Record "Barcode Serial No Stock Take";
        CompInfoRec: Record "Company Information";
        USetup: Record "User Setup";
        ProdOrdH: Record "Production Order";
        ItemJournalLineTemp: Record "IJL Temp";
        Custrec: Record Customer;
        ItemRec: Record Item;


    procedure CredentialsValidate(inputJson: Text): Text[1024]
    var
        UserID: Text[20];
        UserPassword: Text[20];
        UserSetupRec: Record "User Setup";
        Orderjson: JsonObject;
        Myresult: Text[1024];
        jsontext: Text[1024];
        input: JsonObject;
        c: JsonToken;
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
        if UserSetupRec.Get(UserID) then begin
            if (UserPassword.ToUpper() = UserSetupRec.Password) then begin
                Myresult := 'User Login Successfully';
                // Orderjson.Add('id', '1');
                // Orderjson.Add('Success', 'True');
                // Orderjson.Add('Message', Myresult);
                // Orderjson.WriteTo(jsontext);
                // jsontext := jsontext.Replace('\', '');
                jsontext := CreateJsonPayload('1', 'True', Myresult);
                exit(jsontext);
            end else begin
                Myresult := 'Invalid Password';
                Orderjson.Add('id', '0');
                Orderjson.Add('Success', 'False');
                Orderjson.Add('Message', Myresult);
                Orderjson.WriteTo(jsontext);
                jsontext := jsontext.Replace('\', '');
                exit(jsontext);
            end;
        end else begin
            Myresult := 'User not found in User Setup';
            Orderjson.Add('id', '0');
            Orderjson.Add('Success', 'False');
            Orderjson.Add('Message', Myresult);
            Orderjson.WriteTo(jsontext);
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

    procedure ValidateUser(inputJson: Text[1024]): Text[1024]
    var
        input: JsonObject;
        c: JsonToken;
        Myresult: Text[1024];
        Orderjson: JsonObject;
        jsontext: Text[1024];
        // Func parameter
        UserID: Code[30];
        ProcessEnd: Code[30];
        ErrText: Text[250];
        UserName: Text[250];
    begin

        input.ReadFrom(inputJson);
        //Get user ID
        if input.Get('UserID', c) then begin
            UserID := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'UserID Node not found in Payload');
            exit(Myresult);
        end;


        UserSetup.RESET;
        IF UserSetup.GET(UserID) THEN BEGIN
            IF (UserSetup."User Location" <> '') THEN BEGIN
                UserName := UserSetup."User Name";
                ProcessEnd := UserSetup."Process Ending Barcode";
                ErrText := UserSetup."User Location";
                Orderjson.Add('id', '1');
                Orderjson.Add('Success', 'True');
                Orderjson.Add('Message', UserName);
                Orderjson.Add('ProcessEnd', ProcessEnd);
                Orderjson.Add('UserLocation', ErrText);
                Orderjson.WriteTo(jsontext);
                jsontext := jsontext.Replace('\', '');
                exit(jsontext);
            END ELSE BEGIN
                ErrText := 'User location can not be blank';
                jsontext := CreateJsonPayload('0', 'False', ErrText);
                exit(jsontext);
            END;
        END ELSE BEGIN
            ProcessEnd := '';
            ErrText := 'Invalid User ID';
            jsontext := CreateJsonPayload('0', 'False', ErrText);
            exit(jsontext);
        END;
    end;

    procedure GetTemplateBatchName(inputJson: Text[1024]): Text[1024]
    var
        input: JsonObject;
        c: JsonToken;
        UserID: Code[50];
        UserTemplateName: Code[10];
        UserBatchName: Code[10];
        Myresult: Text[1024];
        Orderjson: JsonObject;
    begin

        input.ReadFrom(inputJson);
        //Get user ID
        if input.Get('UserID', c) then begin
            UserID := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'UserID Node not found in Payload');
            exit(Myresult);
        end;

        UserSetup.RESET;
        IF UserSetup.GET(UserID) THEN BEGIN
            UserTemplateName := UserSetup."Journal Template Name";
            UserBatchName := UserSetup."Journal Batch Name";
            Orderjson.Add('id', '1');
            Orderjson.Add('Success', 'True');
            Orderjson.Add('UserTemplateName', UserTemplateName);
            Orderjson.Add('UserBatchName', UserBatchName);
            Orderjson.WriteTo(Myresult);
            Myresult := Myresult.Replace('\', '');
            exit(Myresult);

        END else begin
            Myresult := CreateJsonPayload('0', 'False', UserID + ' UserID not found in User Setup Table');
            exit(Myresult);
        end;


    end;

    procedure ValidateCartonBarcode(inputJson: Text[1024]): Text[1024]
    var
        input: JsonObject;
        PhyLotNo: Text[20];
        ItemNo: Text[20];
        VariantCode: Text[20];
        c: JsonToken;
        Myresult: Text[1024];
        Orderjson: JsonObject;
        jsontext: Text[1024];
        // Func parameter
        CartonBarcodeNO: Code[30];
        ErrText: Text[250];
    begin

        input.ReadFrom(inputJson);
        //Get CartonBarcodeNO
        if input.Get('CartonBarcodeNO', c) then begin
            CartonBarcodeNO := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'CartonBarcodeNO Node not found in Payload');
            exit(Myresult);
        end;

        BSNO.RESET;
        IF BSNO.GET(CartonBarcodeNO) THEN BEGIN
            IF (BSNO."Item Code" <> '') OR (BSNO."Variant Code" <> '') OR (BSNO."Blanket Order No." <> '') THEN BEGIN
                ErrText := 'Carton Barcode already used';
                Orderjson.Add('id', '0');
                Orderjson.Add('Success', 'False');
                Orderjson.Add('BSNO', CartonBarcodeNO);
                Orderjson.Add('ErrText', ErrText);
                Orderjson.WriteTo(jsontext);
                jsontext := jsontext.Replace('\', '');
                exit(jsontext);
            END;
        END ELSE BEGIN
            ErrText := 'Carton Barcode does not exists';
            jsontext := CreateJsonPayload('0', 'False', ErrText);
            exit(jsontext);
        END;
        jsontext := CreateJsonPayload('1', 'True', ErrText);
        exit(jsontext);
    END;

    procedure ValidateEndUser(inputJson: Text[1024]): Text[1024]
    var
        input: JsonObject;
        c: JsonToken;
        Myresult: Text[1024];
        Orderjson: JsonObject;
        jsontext: Text[1024];
        // Func Parameter IN
        EndCode: Code[30];
        UserID: Code[30];
        // Func Parameter Out
        ErrText: Text[250];
        CartonBarcode: Code[30];
        SalesOrder: Code[50];
        WarehouseHeaderFineRec: Record "Warehouse Activity Header";

    begin

        input.ReadFrom(inputJson);
        //Get EndCode
        if input.Get('EndCode', c) then begin
            EndCode := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'EndCode Node not found in Payload');
            exit(Myresult);
        end;

        //Get UserID
        if input.Get('UserID', c) then begin
            UserID := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'UserID Node not found in Payload');
            exit(Myresult);
        end;
        //Get CartonBarcode
        if input.Get('CartonBarcode', c) then begin
            CartonBarcode := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'CartonBarcode Node not found in Payload');
            exit(Myresult);
        end;
        //Get CartonBarcode
        if input.Get('SalesOrder', c) then begin
            SalesOrder := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'SalesOrder Node not found in Payload');
            exit(Myresult);
        end;


        IF UserSetup.GET(UserID) THEN;
        IF (UserSetup."Process Ending Barcode" = EndCode) THEN BEGIN
            System.ClearLastError();
            ErrText := '';

            WarehouseHeaderFineRec.Reset();
            WarehouseHeaderFineRec.SetRange("No.", CartonBarcode);
            WarehouseHeaderFineRec.SetRange(Type, WarehouseHeaderFineRec.Type::"Invt. Pick");
            if WarehouseHeaderFineRec.FindFirst() then begin
                ErrText := 'Warehouse Activity Header Already exit';
                Orderjson.Add('id', '0');
                Orderjson.Add('Success', 'False');
                Orderjson.Add('AssignBarcode', CartonBarcode);
                Orderjson.Add('ErrText', ErrText);
                Orderjson.WriteTo(jsontext);
                jsontext := jsontext.Replace('\', '');
                exit(jsontext);
            end;
            AssignBarcode(CartonBarcode, SalesOrder, UserID);
            ErrText := GetLastErrorText();
            System.ClearLastError();
            if ErrText = '' then begin
                ErrText := 'Carton Barcode is Assigned';
                Orderjson.Add('id', '1');
                Orderjson.Add('Success', 'True');
                Orderjson.Add('AssignBarcode', CartonBarcode);
                Orderjson.Add('ErrText', ErrText);
                Orderjson.WriteTo(jsontext);
                jsontext := jsontext.Replace('\', '');
                exit(jsontext);
            end else begin
                Orderjson.Add('id', '0');
                Orderjson.Add('Success', 'False');
                Orderjson.Add('AssignBarcode', CartonBarcode);
                Orderjson.Add('ErrText', ErrText);
                Orderjson.WriteTo(jsontext);
                jsontext := jsontext.Replace('\', '');
                exit(jsontext);
            end;
        END ELSE BEGIN
            ErrText := 'User ' + UserID + ' End Code is not Valid ';
            jsontext := CreateJsonPayload('0', 'False', ErrText);
            exit(jsontext);
        END;
    END;

    [TryFunction]
    procedure AssignBarcode(CartonBarcode: Code[50]; SalesOrder: Code[50]; UserID: Text[30])
    var
        input: JsonObject;
        PhyLotNo: Text[20];
        ItemNo: Text[20];
        VariantCode: Text[20];
        c: JsonToken;
        Myresult: Text[1024];
        Orderjson: JsonObject;
        jsontext: Text[1024];
        // Func parameter
        ErrText: Text[250];
        WarehouseHeaderFineRec: Record "Warehouse Activity Header";

    begin

        RANDOMIZE();
        LastEntryNo := RANDOM(2147483647);
        BMERec.RESET;

        SalesHeaderRec.RESET;
        SalesHeaderRec.SETRANGE("Document Type", SalesHeaderRec."Document Type"::Order);
        SalesHeaderRec.SETFILTER("No.", SalesOrder);
        IF SalesHeaderRec.FINDFIRST THEN;

        IF BMERec.FINDLAST THEN
            NewEntryNo := BMERec."Entry No." + 1
        ELSE
            NewEntryNo := 1;

        BSNO.GET(CartonBarcode);
        BMERec.RESET;
        BMERec.SETCURRENTKEY(BMERec."Serial No.");
        BMERec.SETRANGE("Serial No.", CartonBarcode);
        IF BMERec.FINDLAST THEN;

        BMERec2.INIT;
        BMERec2."Entry No." := NewEntryNo;
        BMERec2."Entry Type" := BMERec."Entry Type"::Comment;
        BMERec2."Serial No." := BSNO."Serial No.";
        BMERec2.xStatus := BMERec.xStatus;
        BMERec2.Status := BMERec.xStatus;
        BMERec2."xLocation Code" := BMERec."Location Code";
        BMERec2.Comments := 'Carton Assignment';
        BMERec2."Location Code" := BMERec."Location Code";
        //BMERec2."Customer No." := SalesHeader."Sell-to Customer No.";
        //BMERec2."Source Document No." := SalesHeader."Last Shipping No.";
        BMERec2."User ID" := UserCode;
        BSNO."Last Entry No." := BMERec2."Entry No.";
        //BMERec2."Posting Document Type" := BMERec2."Posting Document Type"::"Sales Shipment";
        //BMERec2."Posting Document No." := SalesShptHeader."No.";
        BMERec2."Posting Date" := TODAY;
        BMERec2.INSERT(TRUE);

        BSNO.GET(CartonBarcode);
        BSNO."Blanket Order No." := SalesOrder;
        BSNO."Carton Packed By" := UserID;
        BSNO."Packed Date" := CURRENTDATETIME;
        BSNO.MODIFY(TRUE);



        WarehouseHeaderRec.INIT;
        WarehouseHeaderRec.VALIDATE(Type, WarehouseHeaderRec.Type::"Invt. Pick");
        WarehouseHeaderRec.VALIDATE("No.", CartonBarcode);

        WarehouseHeaderRec.VALIDATE("Carton Packed By", UserID);
        WarehouseHeaderRec.VALIDATE("Source Document", WarehouseHeaderRec."Source Document"::"Sales Order");
        WarehouseHeaderRec.VALIDATE("Location Code", SalesHeaderRec."Location Code");
        WarehouseHeaderRec."Source No." := SalesOrder;
        WarehouseHeaderRec.VALIDATE("Posting Date", TODAY);
        WarehouseHeaderRec.VALIDATE("Shipment Date", TODAY);
        WarehouseHeaderRec.INSERT(TRUE);

        CurrBarcode := '';
        CartonBarcode := '';
        //CLEARALL;
        //jsontext := CreateJsonPayload('0', 'False', ErrText);
        //exit(jsontext);

    END;

    procedure ValidatePieceBarcode(inputJson: Text[1024]): Text[1024]
    var
        input: JsonObject;
        PhyLotNo: Text[20];
        ItemNo: Text[20];
        VariantCode: Text[20];
        c: JsonToken;
        Myresult: Text[1024];
        Orderjson: JsonObject;
        jsontext: Text[1024];
        // Func parameter
        PieceBarcodeL: Text[30];
        ErrText: Text[250];
        ItemCode: Text[30];
        UOM: Code[10];
        ItmCatalogCode: Text[30];
        QtyperUnitofMeasureL: Decimal;
        QuantityBaseL: Decimal;
        QtyperUnitofMeasure: Decimal;
        ItemUnitofMeasureRec: Record 5404;
    begin
        BSNO.RESET();
        IF BSNO.GET(PieceBarcodeL) THEN BEGIN
            IF BSNO."Parent Serial No." <> '' THEN BEGIN
                ErrText := 'This PCS Barcode ' + PieceBarcodeL + ' Already mapped wtih Box Barcode ' + BSNO."Parent Serial No.";
                Orderjson.Add('id', '0');
                Orderjson.Add('BSNO', PieceBarcodeL);
                Orderjson.Add('Success', 'False');
                Orderjson.Add('ErrText', ErrText);
                Orderjson.WriteTo(jsontext);
                jsontext := jsontext.Replace('\', '');
                exit(jsontext);
            END;

            IF BSNO."Unit of Measure Code" = 'BOX' THEN BEGIN
                ErrText := 'BOX Barcode Can not be scanned in Piece Barcode ' + PieceBarcodeL;
                jsontext := CreateJsonPayload('0', 'False', ErrText);
                jsontext := jsontext.Replace('\', '');
                exit(jsontext);
            END;

            QtyperUnitofMeasure := 0;

            IF ItemRec.GET(BSNO."Item Code") THEN BEGIN
                IF ItemUnitofMeasureRec.GET(ItemRec."No.", 'BOX') THEN BEGIN
                    QtyperUnitofMeasure := ItemUnitofMeasureRec."Qty. per Unit of Measure";
                END ELSE BEGIN
                    QtyperUnitofMeasure := 0;
                END;
            END;
            ErrText := 'PCS Barcode not found';
            jsontext := CreateJsonPayload('0', 'False', ErrText);
            exit(jsontext);
        end;
    end;

    PROCEDURE ValidateUserPurchase(UserID: Text[30]; VAR ProcessEnd: Text[30]; VAR ErrText: Text[250]; VAR UserName: Text[250]) flg: Boolean;
    VAR
        PurchUserLocRec: Record "Purchase Header";
        UserSetup: Record "User Setup";
    BEGIN
        UserSetup.RESET;
        IF UserSetup.GET(UserID) THEN BEGIN
            IF (UserSetup."User Location" <> '') THEN BEGIN
                UserName := UserSetup."User Name";
                ProcessEnd := UserSetup."Process Ending Barcode";

                EXIT(True);
            END ELSE BEGIN
                ErrText := 'User location can not be blank';
                EXIT(False);
            END;
        END ELSE BEGIN
            ProcessEnd := '';
            ErrText := 'Invalid User ID';
            EXIT(False);
        END;
    END;

    PROCEDURE CredentialsValidate(UserID: Text[20]; UserPassword: Code[20]; VAR ErrText: Text[500]) Flag: Boolean;
    var
        UserSetup: Record "User Setup";
    BEGIN
        IF UserSetup.GET(UserID) THEN BEGIN
            /*Comment in NAV
            IF(UserSetup."User Location" <> 'PACKING') OR (UserSetup."User Location"<> 'STORE')THEN BEGIN
             ErrText := 'You are not autorized user, due to invalid User Location';
              EXIT(FALSE);
            END;
           */ //Comment in NAV
            IF (UserPassword = UserSetup.Password) THEN BEGIN
                EXIT(TRUE)
            END ELSE BEGIN
                ErrText := 'Invalid Password for this User(' + UserSetup."User ID" + ')';
                EXIT(FALSE);
            END;
        END ELSE BEGIN
            ErrText := 'User does not Exists in User Setup Table';
            EXIT(FALSE);
        END;
    END;

    PROCEDURE ValidateDocumentNoFGManufacturing(inputJson: Text[2024]): Text[1024]
    VAR
        //Function In
        DocumentNo: Code[30];
        UserID: Code[50];

        //Function Out
        TH: Record "Transfer Header";
        THNew: Record "Transfer Header";
        BarcdeSNoRec: Record "Barcode Serial No.";
        DocNo: Code[20];
        ErrText: Text[250];
        input: JsonObject;
        c: JsonToken;
        Myresult: Text[1024];
        Orderjson: JsonObject;
        jsontext: Text[1024];
    BEGIN

        input.ReadFrom(inputJson);
        //Get DocumentNo
        if input.Get('DocumentNo', c) then begin
            DocumentNo := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'DocumentNo Node not found in Payload');
            exit(Myresult);
        end;

        //Get UserID
        if input.Get('UserID', c) then begin
            UserID := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'UID Node not found in Payload');
            exit(Myresult);
        end;


        ManuSetupRec.GET;
        IF NOT UserSetup.GET(UserID) THEN BEGIN
            ErrText := UserID + ' User ID not Found in User Setup Table ';
            Myresult := CreateJsonPayload('0', 'False', ErrText);
            exit(Myresult);
        END else begin
            if UserSetup."Transfer Shpt. From Location" = '' then begin
                ErrText := '{Transfer Shpt. From Location} is blank for user  ' + UserID + ' in User Setup Table ';
                Myresult := CreateJsonPayload('0', 'False', ErrText);
                exit(Myresult);
            end;
        end;

        IF (DocumentNo = 'NEW') THEN BEGIN
            //DocNo := NoSeriesMgt.GetNextNo('TO_PACKING', TODAY, TRUE);
            DocNo := NoSeriesMgt.GetNextNo('ITTO', TODAY, TRUE);
            IF USetup.GET(UserID) THEN BEGIN
                USetup.VALIDATE(TempVal, DocNo);
                USetup.MODIFY;

                TH.INIT;
                TH."No." := DocNo;
                TH.VALIDATE("Posting Date", TODAY);
                TH."Transfer-from Code" := UserSetup."Transfer Shpt. From Location";
                TH."Transfer-to Code" := 'Store';
                TH."In-Transit Code" := 'IN-TRANSIT';
                TH.VALIDATE("Shipment Date", TODAY);
                if TH.INSERT(True) Then begin
                    ErrText := TH."No.";
                    Orderjson.Add('id', '1');
                    Orderjson.Add('Success', 'True');
                    Orderjson.Add('Message', 'Transfer Order created sucessfully');
                    Orderjson.Add('TransferOrderNo', ErrText);
                    Orderjson.WriteTo(jsontext);
                    jsontext := jsontext.Replace('\', '');
                    exit(jsontext);
                end else begin
                    Orderjson.Add('id', '0');
                    Orderjson.Add('Success', 'False');
                    Orderjson.Add('Message', 'Transfer Order not created');
                    Orderjson.Add('TransferOrderNo', '');
                    Orderjson.WriteTo(jsontext);
                    jsontext := jsontext.Replace('\', '');
                    exit(jsontext);
                end;
            END ELSE BEGIN
                ErrText := UserID + ' User Not found in User setup ';
                Myresult := CreateJsonPayload('0', 'False', ErrText);
                exit(Myresult);
            END;
        END ELSE BEGIN
            THNew.RESET;
            THNew.SETRANGE("No.", DocumentNo);
            IF THNew.FINDFIRST THEN BEGIN
                IF USetup.GET(UserID) THEN BEGIN
                    USetup.VALIDATE(TempVal, DocumentNo);
                    USetup.MODIFY;
                End;
                Orderjson.Add('id', '1');
                Orderjson.Add('Success', 'True');
                Orderjson.Add('Message', 'Transfer Order is -' + DocumentNo);
                Orderjson.Add('TransferOrderNo', DocumentNo);
                Orderjson.WriteTo(jsontext);
                jsontext := jsontext.Replace('\', '');
                exit(jsontext);
            END ELSE BEGIN
                Myresult := CreateJsonPayload('1', 'False', DocumentNo + ' Not Found in Barcode Serial No. Table');
                exit(Myresult);
            END;
        END;
    END;


    PROCEDURE ValidateManuSerialNo(inputJson: Text[2024]): Text[1024]
    VAR
        Srlno: Code[20];
        ItemCode: Text[50];
        VariantCode: Text[50];
        Description: Text[50];
        UOM: Code[10];
        Qty: Decimal;
        QTYBase: Decimal;
        PhyLotNo: Code[20];
        ErrText: Text[50];
        ItemMRP: Decimal;
        MinusStr: Code[10];
        BarcodeSerialNoRec: Record "Barcode Serial No.";
        input: JsonObject;
        c: JsonToken;
        Myresult: Text[1024];
        Orderjson: JsonObject;
    BEGIN
        //MSNav++    ********************Manufacturing Module**************************

        input.ReadFrom(inputJson);
        //Get Srlno
        if input.Get('Srlno', c) then begin
            Srlno := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'Srlno Node not found in Payload');
            exit(Myresult);
        end;

        BSNO.RESET;
        MinusStr := '';
        MinusStr := COPYSTR(Srlno, 1, 1);
        IF MinusStr = '-' THEN
            Srlno := DELSTR(Srlno, 1, 1);
        IF NOT (MinusStr = '-') THEN BEGIN
            IF BSNO.GET(Srlno) THEN BEGIN

                //FC 180622 +
                //    BarcodeSerialNoRec.RESET;
                //    BarcodeSerialNoRec.SETCURRENTKEY("Parent Serial No.");
                //    BarcodeSerialNoRec.SETRANGE("Parent Serial No.",Srlno);
                //    IF NOT BarcodeSerialNoRec.FINDFIRST THEN BEGIN
                //      ErrText := 'Selected Barcode is not Mapped with any PCS Barcode ';
                //      EXIT(FALSE);
                //    END;
                //FC 180622 -

                IF (BSNO.Status = BSNO.Status::"Sent to Store") THEN BEGIN
                    ErrText := 'Selected Barcode is already Sent To Store';
                    Orderjson.Add('id', '0');
                    Orderjson.Add('Success', 'False');
                    Orderjson.Add('Message', ErrText);
                    Orderjson.WriteTo(Myresult);
                    Myresult := Myresult.Replace('\', '');
                    exit(Myresult);
                END;

                ItemCode := BSNO."Item Code";
                VariantCode := BSNO."Variant Code";
                Description := BSNO."Item Description";
                UOM := BSNO."Base Unit of Measure";
                Qty := BSNO.Quantity;
                QTYBase := BSNO."Quantity (Base)";
                PhyLotNo := BSNO."Phy. Lot No.";
                ErrText := 'Barcode Validate scucessfully';
                ItemMRP := BSNO.MRP;

                Orderjson.Add('id', '0');
                Orderjson.Add('Success', 'True');
                Orderjson.Add('Message', ErrText);
                Orderjson.Add('ItemCode', ItemCode);
                Orderjson.Add('VariantCode', VariantCode);
                Orderjson.Add('Description', Description);
                Orderjson.Add('UOM', UOM);
                Orderjson.Add('Qty', Qty);
                Orderjson.Add('ItemMRP', ItemMRP);
                Orderjson.Add('QTYBase', QTYBase);
                Orderjson.Add('PhyLotNo', PhyLotNo);
                Orderjson.Add('ErrText', '');
                Orderjson.WriteTo(Myresult);
                Myresult := Myresult.Replace('\', '');
                exit(Myresult);
            END ELSE BEGIN
                ErrText := Srlno + '  Barcode Not Found ';
                Orderjson.Add('id', '0');
                Orderjson.Add('Success', 'False');
                Orderjson.Add('Message', ErrText);
                Orderjson.WriteTo(Myresult);
                Myresult := Myresult.Replace('\', '');
                exit(Myresult);
            END;
        END ELSE BEGIN
            IF BSNO.GET(Srlno) THEN BEGIN
                IF (BSNO.Status = BSNO.Status::"Sent to Store") THEN BEGIN
                    ErrText := 'Selected Barcode is already Sent To Store';
                    Orderjson.Add('id', '0');
                    Orderjson.Add('Success', 'False');
                    Orderjson.Add('Message', ErrText);
                    Orderjson.WriteTo(Myresult);
                    Myresult := Myresult.Replace('\', '');
                    exit(Myresult);
                END;
                ItemCode := BSNO."Item Code";
                VariantCode := BSNO."Variant Code";
                Description := BSNO."Item Description";
                UOM := BSNO."Base Unit of Measure";
                Qty := BSNO.Quantity;
                QTYBase := BSNO."Quantity (Base)";
                PhyLotNo := BSNO."Phy. Lot No.";
                ErrText := 'Barcode Validate scucessfully';
                Orderjson.Add('id', '0');
                Orderjson.Add('Success', 'True');
                Orderjson.Add('Message', ErrText);
                Orderjson.Add('ItemCode', ItemCode);
                Orderjson.Add('VariantCode', VariantCode);
                Orderjson.Add('Description', Description);
                Orderjson.Add('UOM', UOM);
                Orderjson.Add('Qty', Qty);
                Orderjson.Add('ItemMRP', ItemMRP);
                Orderjson.Add('QTYBase', QTYBase);
                Orderjson.Add('PhyLotNo', PhyLotNo);
                Orderjson.Add('ErrText', '');
                Orderjson.WriteTo(Myresult);
                Myresult := Myresult.Replace('\', '');
                exit(Myresult);
            END ELSE BEGIN
                ErrText := Srlno + '  Barcode Not Found ';
                Orderjson.Add('id', '0');
                Orderjson.Add('Success', 'False');
                Orderjson.Add('Message', ErrText);
                Orderjson.WriteTo(Myresult);
                Myresult := Myresult.Replace('\', '');
                exit(Myresult);
            END;
        END;
    END;

    PROCEDURE FGUpdateTransferOrderQty(inputJson: Text[2024]): Text[1024]

    VAR
        Srlno: Code[50];
        ErrText: Text[50];
        UID: Code[50];
        flag: Boolean;
        LastLineNo: Integer;
        TL: Record "Transfer Line";
        BarCodeSrnoRec: Record "Barcode Serial No.";
        MinusStr: Code[10];
        ItemRec: Record Item;
        TLFindRec: Record "Transfer Line";
        Orderjson: JsonObject;
        Myresult: Text[1024];
        input: JsonObject;
        c: JsonToken;
    BEGIN
        input.ReadFrom(inputJson);
        //Get Srlno
        if input.Get('Srlno', c) then begin
            Srlno := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'Srlno Node not found in Payload');
            exit(Myresult);
        end;
        //Get UserID
        if input.Get('UserID', c) then begin
            UID := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'UserID Node not found in Payload');
            exit(Myresult);
        end;
        ManuSetupRec.GET;
        IF NOT UserSetup.GET(UID) THEN BEGIN
            ErrText := UID + ' User ID not Found in User Setup Table ';
            Orderjson.Add('id', '0');
            Orderjson.Add('Success', 'False');
            Orderjson.Add('Message', ErrText);
            Orderjson.WriteTo(Myresult);
            Myresult := Myresult.Replace('\', '');
            exit(Myresult);
        END else begin
            if UserSetup.TempVal = '' then begin
                ErrText := UID + ' {TempVal} field is blank for user ' + UID + ' in User Setup Table ';
                Orderjson.Add('id', '0');
                Orderjson.Add('Success', 'False');
                Orderjson.Add('Message', ErrText);
                Orderjson.WriteTo(Myresult);
                Myresult := Myresult.Replace('\', '');
                exit(Myresult);
            end;
        end;

        MinusStr := '';
        MinusStr := COPYSTR(Srlno, 1, 1);
        IF MinusStr = '-' THEN
            Srlno := DELSTR(Srlno, 1, 1);
        IF BSNO.GET(Srlno) THEN BEGIN
            IF USetup.GET(UID) THEN BEGIN
                /*
                IF BSNO."Transfer Order No." <> '' THEN BEGIN
                         ERROR('Duplcate Barcode');
                     END;
                */
                TransferHdr.RESET;
                TransferHdr.SETRANGE("No.", USetup.TempVal);
                //IF TransferHdr."Transfer-to Code"='ECOM' THEN
                IF TransferHdr.FINDFIRST THEN BEGIN
                    TLFindRec.RESET;
                    TLFindRec.SETRANGE("Document No.", USetup.TempVal);
                    TLFindRec.SETRANGE("Item No.", BSNO."Item Code");
                    TLFindRec.SETRANGE("Variant Code", BSNO."Variant Code");
                    TLFindRec.SETRANGE("Phy. Lot No.", BSNO."Phy. Lot No.");
                    IF NOT TLFindRec.FINDFIRST THEN BEGIN
                        TransferLine.INIT;
                        TransferLine."Document No." := TransferHdr."No.";
                        TL.RESET;
                        TL.SETRANGE("Document No.", TransferHdr."No.");
                        IF TL.FINDLAST THEN
                            LastLineNo := TL."Line No." + 10000
                        ELSE
                            LastLineNo := 10000;

                        TransferLine."Line No." := LastLineNo;
                        TransferLine.VALIDATE("Item No.", BSNO."Item Code");
                        TransferLine."Transfer-to Code" := TransferHdr."Transfer-to Code";
                        TransferLine."Variant Code" := BSNO."Variant Code";

                        TransferLine.Description := BSNO."Item Description";
                        //FC TransferLine."Unit of Measure Code" := BSNO."Base Unit of Measure";
                        IF ItemRec.GET(BSNO."Item Code") THEN;
                        TransferLine.VALIDATE("Unit of Measure Code", ItemRec."Sales Unit of Measure");

                        //FC +
                        IF (ItemRec."Sales Unit of Measure" = 'DOZ') AND (BSNO."Base Unit of Measure" = 'DOZ') THEN BEGIN
                            TransferLine.VALIDATE(Quantity, BSNO."Quantity (Base)")
                        END ELSE
                            IF (ItemRec."Sales Unit of Measure" = 'PCS') AND (BSNO."Base Unit of Measure" = 'PCS') THEN BEGIN
                                TransferLine.VALIDATE(Quantity, BSNO."Quantity (Base)")
                            END ELSE
                                IF (ItemRec."Sales Unit of Measure" = 'DOZ') AND (BSNO."Base Unit of Measure" = 'PCS') THEN BEGIN
                                    TransferLine.VALIDATE(Quantity, BSNO."Quantity (Base)" / 12);
                                END;

                        TransferLine."Phy. Lot No." := BSNO."Phy. Lot No.";
                        TransferLine."MRP Price" := BSNO.MRP;

                        TransferLine."Reason Code" := 'PRODUCTION';
                        //QTYBase := BSNO."Quantity (Base)";
                        //PhyLotNo:=BSNO."Phy. Lot No.";
                        TransferLine.INSERT;
                        IF BarCodeSrnoRec.GET(Srlno) THEN BEGIN
                            BarCodeSrnoRec.VALIDATE(Status, BarCodeSrnoRec.Status::"Sent to Store");
                            BarCodeSrnoRec.VALIDATE("Output Date", TODAY);
                            BarCodeSrnoRec.VALIDATE("X Location", UserSetup."User Location");
                            BarCodeSrnoRec.Tracking := BarCodeSrno.Tracking::Production;
                            BarCodeSrnoRec."Transfer Order No." := TransferHdr."No.";
                            BarCodeSrnoRec.Modify(True);
                        End;

                        ErrText := 'Transfer Line ' + TransferLine."Document No." + ' Sucessfully Created ';
                        Orderjson.Add('id', '1');
                        Orderjson.Add('Success', 'True');
                        Orderjson.Add('Message', ErrText);
                        Orderjson.WriteTo(Myresult);
                        Myresult := Myresult.Replace('\', '');
                        exit(Myresult);
                    END ELSE BEGIN
                        //FC +
                        IF ItemRec.GET(BSNO."Item Code") THEN;
                        IF (ItemRec."Sales Unit of Measure" = 'DOZ') AND (BSNO."Base Unit of Measure" = 'DOZ') THEN BEGIN
                            TLFindRec.VALIDATE(Quantity, TLFindRec.Quantity + BSNO."Quantity (Base)")
                        END ELSE
                            IF (ItemRec."Sales Unit of Measure" = 'PCS') AND (BSNO."Base Unit of Measure" = 'PCS') THEN BEGIN
                                TLFindRec.VALIDATE(Quantity, TLFindRec.Quantity + BSNO."Quantity (Base)")
                            END ELSE
                                IF (ItemRec."Sales Unit of Measure" = 'DOZ') AND (BSNO."Base Unit of Measure" = 'PCS') THEN BEGIN
                                    TLFindRec.VALIDATE(Quantity, TLFindRec.Quantity + BSNO."Quantity (Base)" / 12);
                                END;
                        TLFindRec.MODIFY(TRUE);
                        IF BarCodeSrnoRec.GET(Srlno) THEN BEGIN
                            BarCodeSrnoRec.VALIDATE(Status, BarCodeSrnoRec.Status::"Sent to Store");
                            BarCodeSrnoRec.VALIDATE("Output Date", TODAY);
                            BarCodeSrnoRec.VALIDATE("X Location", UserSetup."User Location");
                            BarCodeSrnoRec.Tracking := BarCodeSrno.Tracking::Production;
                            BarCodeSrnoRec."Transfer Order No." := TransferHdr."No.";
                            BarCodeSrnoRec.Modify(True);
                        End;
                        ErrText := 'Transfer Line ' + TransferLine."Document No." + ' Sucessfully Modify ';
                        Orderjson.Add('id', '1');
                        Orderjson.Add('Success', 'True');
                        Orderjson.Add('Message', ErrText);
                        Orderjson.WriteTo(Myresult);
                        Myresult := Myresult.Replace('\', '');
                        exit(Myresult);
                        //FC -
                    END;
                END else begin
                    ErrText := 'Transfer Order No. ' + USetup.TempVal + ' Not found in Transfer Header Table ';
                    Orderjson.Add('id', '0');
                    Orderjson.Add('Success', 'False');
                    Orderjson.Add('Message', ErrText);
                    Orderjson.WriteTo(Myresult);
                    Myresult := Myresult.Replace('\', '');
                    exit(Myresult);
                end;
            END;
        END;
    END;


    PROCEDURE ValidateSalesOrder(inputJson: Text[2024]): Text[1024]
    var
        //In
        OrderNo: Code[50];
        //Out
        BTC: Text[1024];
        OrderStatus: Boolean;
        ErrTxt: Text[250];

        input: JsonObject;
        c: JsonToken;
        Myresult: Text[1024];
        Orderjson: JsonObject;


    BEGIN
        input.ReadFrom(inputJson);
        //Get OrderNo
        if input.Get('OrderNo', c) then begin
            OrderNo := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'OrderNo Node not found in Payload');
            exit(Myresult);
        end;

        SalesHeaderRec.RESET;
        IF SalesHeaderRec.GET(SalesHeaderRec."Document Type"::Order, OrderNo) THEN BEGIN
            IF SalesHeaderRec.Closed = TRUE THEN BEGIN
                ErrTxt := 'Sales Order already closed';
                OrderNo := '';
                OrderStatus := FALSE;

                Orderjson.Add('id', '0');
                Orderjson.Add('Success', 'False');
                Orderjson.Add('BTC', SalesHeaderRec."Bill-to Name");
                Orderjson.Add('OrderStatus', OrderStatus);
                Orderjson.Add('ErrTxt', ErrTxt);
                Orderjson.WriteTo(Myresult);
                Myresult := Myresult.Replace('\', '');
                exit(Myresult);
            END ELSE BEGIN
                IF (SalesHeaderRec."Location Code" <> '') THEN BEGIN
                    OrderStatus := TRUE;
                    BTC := SalesHeaderRec."Bill-to Name";
                    Orderjson.Add('id', '0');
                    Orderjson.Add('Success', 'True');
                    Orderjson.Add('BTC', SalesHeaderRec."Bill-to Name");
                    Orderjson.Add('OrderStatus', OrderStatus);
                    Orderjson.Add('ErrTxt', ErrTxt);
                    Orderjson.WriteTo(Myresult);
                    Myresult := Myresult.Replace('\', '');
                    exit(Myresult);
                END ELSE BEGIN
                    ErrTxt := 'Sales order Shipping Location cannot be blank';
                    Orderjson.Add('id', '0');
                    Orderjson.Add('Success', 'False');
                    Orderjson.Add('BTC', SalesHeaderRec."Bill-to Name");
                    Orderjson.Add('OrderStatus', 'False');
                    Orderjson.Add('ErrTxt', ErrTxt);
                    Orderjson.WriteTo(Myresult);
                    Myresult := Myresult.Replace('\', '');
                    exit(Myresult);
                END
            END;
        END ELSE BEGIN
            ErrTxt := ' Sales Order Does not exit';
            OrderNo := '';
            OrderStatus := FALSE;

            Orderjson.Add('id', '0');
            Orderjson.Add('Success', 'False');
            Orderjson.Add('BTC', SalesHeaderRec."Bill-to Name");
            Orderjson.Add('OrderStatus', 'False');
            Orderjson.Add('ErrTxt', ErrTxt);
            Orderjson.WriteTo(Myresult);
            Myresult := Myresult.Replace('\', '');
            exit(Myresult);

        END;
    END;


    PROCEDURE ValidatePBarcode(inputJson: Text[2024]): Text[1024]
    Var
        //Function In
        ParentBarcode: Code[30];
        //Function Out
        ErrText: Text[250];
        OrderNoCode: Code[30];

        input: JsonObject;
        c: JsonToken;
        Myresult: Text[1024];
        Orderjson: JsonObject;
        OrderNo: Code[50];

    BEGIN
        input.ReadFrom(inputJson);
        //Get ParentBarcode
        if input.Get('ParentBarcode', c) then begin
            ParentBarcode := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'ParentBarcode Node not found in Payload');
            exit(Myresult);
        end;

        BSNO.RESET();
        IF BSNO.GET(ParentBarcode) THEN BEGIN
            IF BSNO."Blanket Order No." <> '' THEN BEGIN
                WarehouseHeaderRec.RESET;
                //mukesh
                IF (SalesHeader."Sell-to Customer No." = 'C897') AND (SalesHeader."Sell-to Customer No." = 'C685') THEN begin
                    ErrText := 'Supply Is Hold';
                    Myresult := CreateJsonPayload('0', 'False', ErrText);
                    exit(Myresult);
                end;

                //mukesh
                IF SalesHeader.GET(SalesHeader."Document Type"::Order, BSNO."Blanket Order No.") THEN BEGIN
                    IF SalesHeader.ScanLock THEN BEGIN
                        ErrText := 'Please Wait until Sales Invoicing has been made for Order No. ' + BSNO."Blanket Order No.";
                        Myresult := CreateJsonPayload('0', 'False', ErrText);
                        exit(Myresult);
                    END;
                END;


                IF Custrec.GET(SalesHeader."Sell-to Customer No.") THEN BEGIN
                    IF (Custrec.Requirement <> '') THEN begin
                        ErrText := 'Please pack' + Custrec.Requirement + ' with order goods';
                        Myresult := CreateJsonPayload('0', 'False', ErrText);
                        exit(Myresult);
                    end;
                END;

                IF NOT WarehouseHeaderRec.GET(WarehouseHeaderRec.Type::"Invt. Pick", ParentBarcode) THEN BEGIN
                    ErrText := 'Pick List Header ' + ParentBarcode + ' Does Not Exits ';
                    ParentBarcode := '';
                    Myresult := CreateJsonPayload('0', 'False', ErrText);
                    exit(Myresult);
                END;
                ErrText := 'Carton is assigned to ' + BSNO."Blanket Order No." + ' Sales Order No.';
                OrderNo := BSNO."Blanket Order No.";
                Orderjson.Add('id', '1');
                Orderjson.Add('Success', 'True');
                Orderjson.Add('Message', ErrText);
                Orderjson.Add('OrderNo', OrderNo);
                Orderjson.WriteTo(Myresult);
                Myresult := Myresult.Replace('\', '');
                exit(Myresult);

            END ELSE BEGIN
                ErrText := 'Carton Barcode is not assigned to Sales Order';
                OrderNo := '';
                Orderjson.Add('id', '0');
                Orderjson.Add('Success', 'False');
                Orderjson.Add('Message', ErrText);
                Orderjson.Add('OrderNo', OrderNo);
                Orderjson.WriteTo(Myresult);
                Myresult := Myresult.Replace('\', '');
                exit(Myresult);
            END;
        END ELSE BEGIN
            ErrText := 'Carton Barcode not found';
            OrderNo := '';
            Orderjson.Add('id', '0');
            Orderjson.Add('Success', 'False');
            Orderjson.Add('Message', ErrText);
            Orderjson.Add('OrderNo', OrderNo);
            Orderjson.WriteTo(Myresult);
            Myresult := Myresult.Replace('\', '');
            exit(Myresult);
        END;
    END;


    PROCEDURE ValidateCBarcode(inputJson: Text[2024]): Text[1024]
    VAR
        //Functioin In
        Barcode: Code[30];

        //Functioin Out
        ErrText: Text[1024];
        ItemCode: Text[30];
        VariantCode: Text[30];
        UOM: Code[10];
        ItmCatalogCode: Text[30];
        Flag: Boolean;

        input: JsonObject;
        c: JsonToken;
        Myresult: Text[1024];
        Orderjson: JsonObject;

        UserSetupRec: Record "User Setup";
        DateVar: Date;
    BEGIN
        //DateVar := 201121D;
        DateVar := 20211121D;

        input.ReadFrom(inputJson);
        //Get ParentBarcode
        if input.Get('Barcode', c) then begin
            Barcode := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'Barcode Node not found in Payload');
            exit(Myresult);
        end;

        CLEAR(BSNO);

        IF BSNO.GET(Barcode) THEN BEGIN

            IF Custrec.GET(SalesHeader."Sell-to Customer No.") THEN
                IF SalesHeader.GET(SalesHeader."Document Type"::Order, BSNO."Blanket Order No.") THEN BEGIN
                    IF SalesHeader.ScanLock THEN BEGIN
                        ErrText := 'Please Wait until Sales Invoicing has been made for Order No. ' + BSNO."Blanket Order No.";
                        //EXIT(FALSE);
                        Myresult := CreateJsonPayload('0', 'False', ErrText);
                        exit(Myresult);
                    END;
                END;

            IF Custrec.GET(SalesHeader."Sell-to Customer No.") THEN BEGIN
                IF SalesLineRec."Location Code" = 'STORE' THEN
                    IF (Custrec.Requirement <> '') THEN begin
                        ErrText := 'Please pack' + Custrec.Requirement + ' with order goods';
                        Myresult := CreateJsonPayload('0', 'False', ErrText);
                        exit(Myresult);
                    end;
            END;

            IF BSNO."Parent Serial No." <> '' THEN BEGIN
                ErrText := 'Barcode is already Assigned ';
                //EXIT(FALSE);
                Myresult := CreateJsonPayload('0', 'False', ErrText);
                exit(Myresult);

            END ELSE BEGIN

                //mukesh

                IF BSNO."Creation Date" < 20211121D THEN BEGIN
                    ErrText := 'Creation date is before 01Nov2021';
                    //EXIT(FALSE);
                    Myresult := CreateJsonPayload('0', 'False', ErrText);
                    exit(Myresult);
                END;

                IF BSNO."Creation Date" = 0D THEN BEGIN
                    ErrText := 'This item could not be sale before scanned';
                    //EXIT(FALSE);
                    Myresult := CreateJsonPayload('0', 'False', ErrText);
                    exit(Myresult);
                END;
                //mukesh

                IF BSNO."Creation Date" < DateVar THEN BEGIN
                    IF UserSetupRec.GET(BSNO.CreatedBy) THEN BEGIN
                        IF NOT UserSetupRec.Scan THEN BEGIN
                            IF BSNO."Creation Date" = 0D THEN BEGIN
                                ErrText := 'This item could not be sale before scanned';
                                //EXIT(FALSE);
                                Myresult := CreateJsonPayload('0', 'False', ErrText);
                                exit(Myresult);
                            END ELSE
                                IF BSNO."Creation Date" > 20211121D THEN BEGIN
                                    ErrText := 'Creation date is before 01Nov2021';
                                    //EXIT(FALSE);
                                    Myresult := CreateJsonPayload('0', 'False', ErrText);
                                    exit(Myresult);
                                END;
                        END;
                    END;
                END;
                //arvind20150721
                WarehouseLineRec.RESET;
                WarehouseLineRec.SETRANGE("Activity Type", WarehouseLineRec."Activity Type"::"Invt. Pick");
                //  WarehouseLineRec.SETRANGE(WarehouseLineRec."No.",ParentBarcode);
                WarehouseLineRec.SETRANGE(WarehouseLineRec.ItemBarcode, Barcode);
                IF WarehouseLineRec.FINDFIRST THEN BEGIN
                    ErrText := Barcode + ' Barcode Already Scan in Pick List ';
                    //ErrorBeep; //Selected Barcode is already in use
                    Barcode := '';
                    //EXIT(FALSE);
                    Myresult := CreateJsonPayload('0', 'False', ErrText);
                    exit(Myresult);
                END ELSE BEGIN
                    IF BSNO."Item Category Code" <> 'NIGHTWEAR' THEN
                        IF BSNO."Unit of Measure Code" = 'PCS' THEN BEGIN
                            ErrText := 'UOM of Selected Barcode is PCS';
                            //EXIT(FALSE);
                            Myresult := CreateJsonPayload('0', 'False', ErrText);
                            exit(Myresult);
                        END;
                END;
                ItemCode := BSNO."Item Code";
                UOM := BSNO."Base Unit of Measure";
                VariantCode := BSNO."Variant Code";
                ItmCatalogCode := BSNO."Item Category Code";
                //EXIT(TRUE);
                Orderjson.Add('id', '1');
                Orderjson.Add('Success', 'True');
                Orderjson.Add('Message', 'Done');
                Orderjson.Add('ItemCode', ItemCode);
                Orderjson.Add('UOM', UOM);
                Orderjson.Add('VariantCode', VariantCode);
                Orderjson.Add('ItmCatalogCode', ItmCatalogCode);
                Orderjson.WriteTo(Myresult);
                Myresult := Myresult.Replace('\', '');
                exit(Myresult);

            END;

        END ELSE BEGIN
            ErrText := 'Barcode not exists';
            //EXIT(FALSE);
            Myresult := CreateJsonPayload('1', 'True', ErrText);
            exit(Myresult);
        END;
    END;


    PROCEDURE BarcodePacking(inputJson: Text[2024]): Text[1024]
    VAR
        //Function In
        ParentBarcode: Code[30];
        ChildBarcode: Code[30];
        UserID: Code[30];
        //Function Out
        ErrText: Text[250];
        Flag: Boolean;

        ErrL: Text[250];
        BSNORec: Record "Barcode Serial No.";

        input: JsonObject;
        c: JsonToken;
        Myresult: Text[1024];
        Orderjson: JsonObject;


    BEGIN

        input.ReadFrom(inputJson);
        //Get ParentBarcode
        if input.Get('ParentBarcode', c) then begin
            ParentBarcode := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'ParentBarcode Node not found in Payload');
            exit(Myresult);
        end;

        //Get ChildBarcode
        if input.Get('ChildBarcode', c) then begin
            ChildBarcode := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'ChildBarcode Node not found in Payload');
            exit(Myresult);
        end;

        //Get UserID
        if input.Get('UserID', c) then begin
            UserID := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'UserID Node not found in Payload');
            exit(Myresult);
        end;



        IF BSNO.GET(ChildBarcode) THEN BEGIN
            ParentBSNORec.GET(ParentBarcode);
            SalesHeaderRec.GET(SalesHeaderRec."Document Type"::Order, ParentBSNORec."Blanket Order No.");
            /*
            IF (SalesHeaderRec."Sell-to Customer No." = 'C348') AND (SalesHeaderRec."Sell-to Customer No." = 'C053') THEN BEGIN
                    IF BSNO."Creation Date" < 311218D THEN BEGIN
                        ErrText := 'Creation date is before 31Dec2018';
                        EXIT(FALSE);
                    END;
                END;
            }
            */
            IF (SalesHeaderRec."Sell-to Customer No." = 'C767') AND (SalesHeaderRec."Sell-to Customer No." = 'C660')
              AND (SalesHeaderRec."Sell-to Customer No." = 'C646') AND (SalesHeaderRec."Sell-to Customer No." = 'C656') AND (SalesHeaderRec."Sell-to Customer No." = 'C682')
             AND (SalesHeaderRec."Sell-to Customer No." = 'C854') THEN BEGIN
                IF BSNO."Creation Date" < 20200101D THEN BEGIN
                    ErrText := 'Creation date should not be before 01Jan2020';
                    //EXIT(FALSE);
                    Myresult := CreateJsonPayload('0', 'False', ErrText);
                    exit(Myresult);
                END;
            END;

            //SalesLineRec
            IF NOT ShipTOBarcode(SalesHeaderRec, BSNO."Serial No.", ErrL, FALSE, 123, UserID, ParentBarcode) THEN BEGIN
                ChildBarcode := '';
                ErrText := ErrL;
                Myresult := CreateJsonPayload('0', 'False', ErrText);
                exit(Myresult);
            END ELSE BEGIN
                IF ParentBarcode <> '' THEN BEGIN
                    BSNORec.GET(ChildBarcode);
                    BSNORec."Parent Serial No." := ParentBarcode;
                    BSNORec.MODIFY(TRUE);
                END;

                ErrText := '';
                //EXIT(TRUE);
                Myresult := CreateJsonPayload('1', 'True', ErrText);
                exit(Myresult);
            END;
        END;
    END;





    procedure ShipTOBarcode(SalesHeaderRec: Record "Sales Header"; ItemBarcode: Code[20]; VAR ErrorText: Text[250]; IsRemoved: Boolean; BuffEntNo: Integer; CurrUserID: Code[20]; ParentBarcode: Code[20]): Boolean
    //if not IsRemoved then
    var
        CustomerPriceGroupCodeOld: code[20];
        CustomerPriceGroupCode: code[20];
        CustomerPriceGroupCodetemp: Code[20];
        CustRec: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLineRecord: Record "Sales Line";
        BarcodeRec: Record 50019;
        QtyToShip: Decimal;
        OriginalQtyToShip: Decimal;
        ParentCodeG: code[20];
        SalesLineNoRec: Record "Sales Line";
        LastSalesLineNo: Integer;
        SplitFlg: Boolean;
        Barcodedec: Decimal;
        Flg: Boolean;
        AvailableSalesline: Record "Sales Line";
        SalesLineInsertRec: Record "Sales Line";
        PickQty: Decimal;
        BarcodeMRP: Decimal;
        QtyBase: Decimal;
        QtyBase1: Decimal;
        SaLnInsertRec: Record 37;
        BarcodeCustPriceGroupCode: Code[20];
        UsedQty: Decimal;
        PickListRec: Record 5767;
        Bsno: Record "Barcode Serial No.";
        LineNo: Integer;
        i: Integer;
        QtytoShipNew: Decimal;
    begin
        IF NOT IsRemoved THEN
            WITH SalesHeaderRec DO BEGIN
                CustomerPriceGroupCodeOld := '';
                CustomerPriceGroupCode := '';
                CustomerPriceGroupCodetemp := '';
                IF CustRec.GET("Sell-to Customer No.") THEN BEGIN
                    CustomerPriceGroupCodeOld := CustRec."Customer Price Group Old";
                    CustomerPriceGroupCode := CustRec."Customer Price Group";
                    CustomerPriceGroupCodetemp := CustRec."Customer Price Group_Temp";
                    //mukesh
                    IF (CustomerPriceGroupCodeOld = 'WSP_2018') AND (CustomerPriceGroupCode = 'WSP_2018') AND (CustomerPriceGroupCodetemp = 'WSP_2018') THEN begin
                        ErrorText := 'OLD Price Can Not Be Dispatched';
                        exit(false);
                    end;

                    IF (SalesHeaderRec."Sell-to Customer No." = 'C201') AND (SalesHeaderRec."Sell-to Customer No." = 'C191') AND (SalesHeaderRec."Sell-to Customer No." = 'C215') AND (SalesHeaderRec."Sell-to Customer No." = 'C156')
                      AND (SalesHeaderRec."Sell-to Customer No." = 'C897') AND (SalesHeaderRec."Sell-to Customer No." = 'C685') THEN begin
                        ErrorText := 'SUPPLY IS HOLD';
                        exit(false);
                    end;
                    //mukesh check
                    IF CustRec.GET(SalesHeader."Sell-to Customer No.") THEN BEGIN
                        IF (CustRec.Requirement <> '') THEN begin
                            ErrorText := 'Please pack' + CustRec.Requirement + ' with order goods';
                            exit(false);
                        end;
                    END;

                    IF CustRec.Blocked = CustRec.Blocked::All THEN BEGIN
                        IF (SalesHeaderRec."Sell-to Customer No." = 'C201') THEN
                            IF SalesLineRecord."Sell-to Customer No." = 'C201' THEN
                                ErrorText := 'Customer is blocked card ';
                        if (ErrorText <> '') then begin
                            EXIT(FALSE);
                        end;
                    END;
                END;

                IF (CustomerPriceGroupCodeOld = '') AND (CustomerPriceGroupCode = '') AND (CustomerPriceGroupCodetemp = '') THEN BEGIN
                    ErrorText := 'Customer Price Group Code Not found in customer card ';
                    //ERROR(ErrorText);
                    EXIT(FALSE);
                END;

                IF (SalesLineRecord."Sell-to Customer No." = 'C201') AND (SalesLineRecord."Sell-to Customer No." = 'C191') AND (SalesLineRecord."Sell-to Customer No." = 'C215') AND (SalesLineRecord."Sell-to Customer No." = 'C156')
                    AND (SalesLineRecord."Sell-to Customer No." = 'C897') AND (SalesLineRecord."Sell-to Customer No." = 'C685') THEN begin
                    ErrorText := 'SUPPLY IS HOLD';
                    EXIT(FALSE);
                end;

                IF CustRec.GET(SalesHeaderRec."Sell-to Customer No.") THEN BEGIN
                    IF (CustRec.Requirement <> '') THEN begin
                        ErrorText := 'Please pack' + CustRec.Requirement + ' with order goods';
                        EXIT(FALSE);
                    end;
                END;


                BarcodeRec.GET(ItemBarcode);
                //PBS MAN 161216 UOM Change
                //QtyToShip := BarcodeRec."Quantity (Base)";
                IF BarcodeRec."Base Unit of Measure" = 'PCS' THEN BEGIN
                    QtyToShip := BarcodeRec."Quantity (Base)";
                END ELSE BEGIN
                    QtyToShip := BarcodeRec."Quantity (Base)" * 12;
                END;
                //PBS MAN 161216 UOM Change
                OriginalQtyToShip := QtyToShip;
                ParentCodeG := ParentBarcode;
                //IF BarcodeRec."Unit of Measure Code"='BOX' THEN BEGIN
                //IF SalesLineRecord."MRP Price"=0 THEN
                IF (BarcodeRec.MRP = 0) AND (BarcodeRec."Item Code" <> '') THEN BEGIN
                    ErrorText := 'MRP is Zero in Barcode Serial No. ';
                    //ERROR(ErrorText);
                    EXIT(FALSE);
                END;
                //END;

                //FC MIL 310315 +
                //IF NOT (BarcodeRec.Tracking IN [BarcodeRec.Tracking::" ",BarcodeRec.Tracking::Production,
                //BarcodeRec.Tracking::"Stock Taking",BarcodeRec.Tracking::"Goods Return",BarcodeRec.Tracking::Transfer]) THEN BEGIN
                //  ErrorText :='Item Not Included either Stock Take or Production ';
                //  ERROR(ErrorText);
                //  EXIT(FALSE);
                //END;
                //FC MIL 310315 -

                //FC MIL 210815 +

                IF (BarcodeRec.Tracking IN [BarcodeRec.Tracking::" "]) THEN BEGIN
                    ErrorText := 'Item Not Included either Stock Take or Production ';
                    //ERROR(ErrorText);
                    EXIT(FALSE);
                END;

                //FC MIL 210815 -

                //To Get Last Line in Sales Order
                CLEAR(SalesLineNoRec);
                SalesLineNoRec.RESET;
                SalesLineNoRec.SETRANGE("Document Type", "Document Type");
                SalesLineNoRec.SETRANGE("Document No.", "No.");
                LastSalesLineNo := 0;
                IF SalesLineNoRec.FINDLAST THEN
                    LastSalesLineNo := SalesLineNoRec."Line No."
                ELSE
                    LastSalesLineNo := 0;

                SplitFlg := FALSE;

                CLEAR(SalesLineRecord);

                SalesLineRecord.RESET;
                SalesLineRecord.SETRANGE("Document Type", "Document Type");
                SalesLineRecord.SETRANGE("Document No.", "No.");
                SalesLineRecord.SETRANGE(Type, SalesLineRecord.Type::Item);
                SalesLineRecord.SETFILTER("No.", '%1', BarcodeRec."Item Code");
                SalesLineRecord.SETRANGE("Variant Code", BarcodeRec."Variant Code");
                SalesLineRecord.SETFILTER("Outstanding Quantity", '<>%1', 0);
                SalesLineRecord.SETRANGE(Closed, FALSE);
                IF SalesLineRecord.FINDFIRST THEN
                    REPEAT

                        //FC 290423 +
                        if (SalesLineRecord."Unit of Measure Code" <> BarcodeRec."Base Unit of Measure") then begin
                            //QtyToShip := QtyToShip / 12;
                        end;
                        //FC 290423 -

                        //IF SalesLineRecord.Closed THEN BEGIN
                        //  ErrorText :='Line No. '+FORMAT(SalesLineRecord."Line No.")+' is already Closed';
                        //  EXIT(FALSE);
                        //END;

                        IF (SalesLineRecord."Unit Price" = 0) OR (SalesLineRecord."MRP Price" = 0) THEN BEGIN
                            ErrorText := 'Unit Price/MRP is Zero in Line No. ' + FORMAT(SalesLineRecord."Line No.");
                            EXIT(FALSE);
                        END;
                        IF SalesLineRecord."Unit of Measure Code" = 'DOZ' THEN BEGIN
                            Barcodedec := BarcodeRec.MRP * 12;
                        END ELSE BEGIN
                            Barcodedec := BarcodeRec.MRP;
                        END;
                        IF (Barcodedec <> GetNewMRP_PBS(BarcodeRec."Item Code", BarcodeRec."Variant Code", CustomerPriceGroupCodeOld, SalesLineRecord."Unit of Measure Code")) AND
                          (Barcodedec <> GetNewMRP_PBS(BarcodeRec."Item Code", BarcodeRec."Variant Code", CustomerPriceGroupCodetemp, SalesLineRecord."Unit of Measure Code")) AND
                        (Barcodedec <> GetNewMRP_PBS(BarcodeRec."Item Code", BarcodeRec."Variant Code", CustomerPriceGroupCode, SalesLineRecord."Unit of Measure Code")) THEN BEGIN

                            ErrorText := 'Barcode MRP ' + FORMAT(Barcodedec) + 'is not compatible with either Old MRP ' +
                            FORMAT(GetNewMRP_PBS(BarcodeRec."Item Code", BarcodeRec."Variant Code", CustomerPriceGroupCodeOld, SalesLineRecord."Unit of Measure Code")) +
                             ' or New MRP ' +
                            FORMAT(GetNewMRP_PBS(BarcodeRec."Item Code", BarcodeRec."Variant Code", CustomerPriceGroupCode, SalesLineRecord."Unit of Measure Code"));
                            EXIT(FALSE);
                            BarcodeRec."Parent Serial No." := '';
                            BarcodeRec.MODIFY;
                        END;

                        //FC Nida +
                        IF SalesLineRecord."Outstanding Qty. (Base)" < BarcodeRec."Quantity (Base)" THEN BEGIN
                            ErrorText := 'Order Qty.(' + FORMAT(SalesLineRecord."Outstanding Quantity") + ') is less than packing qty. (' + FORMAT(BarcodeRec."Quantity (Base)") + ')';
                            EXIT(FALSE);
                        END;

                        //FC 241216 +
                        IF (BarcodeRec."Base Unit of Measure" = 'PCS') AND (BarcodeRec."Quantity (Base)" = 1) AND (BarcodeRec."Unit of Measure Code" = 'DOZ') THEN BEGIN
                            ErrorText := 'Base Unit of Measure=''PCS'' AND "Quantity (Base)"=1 "Unit of Measure Code"=''BOX'' ';
                            EXIT(FALSE);
                        END;

                        //FC 241216 -

                        //FC Nida -

                        Flg := FALSE;
                        SalesLineRecord.CALCFIELDS("Pick Quantity");
                        PickQty := SalesLineRecord."Pick Quantity";
                        IF SalesLineRecord."Unit of Measure Code" = 'DOZ' THEN BEGIN //PBS MAN 300716
                            BarcodeMRP := BarcodeRec.MRP * 12;
                        END ELSE BEGIN
                            BarcodeMRP := BarcodeRec.MRP;
                        END;
                        //IF PickQty < SalesLineRecord."Outstanding Qty. (Base)"   THEN BEGIN //Pick Qty Check
                        IF PickQty < SalesLineRecord."Outstanding Quantity" THEN BEGIN //Pick Qty Check
                            IF BarcodeMRP <> SalesLineRecord."MRP Price" THEN BEGIN
                                //PBS MAN 300417
                                IF BarcodeRec."Base Unit of Measure" <> SalesLineRecord."Unit of Measure Code" THEN BEGIN
                                    IF BarcodeRec."Base Unit of Measure" = 'PCS' THEN BEGIN
                                        QtyBase := (BarcodeRec.Quantity * BarcodeRec."Quantity Per") / 12;
                                        QtyBase1 := QtyBase / BarcodeRec.Quantity;
                                    END ELSE BEGIN
                                        QtyBase := (BarcodeRec.Quantity * BarcodeRec."Quantity Per") * 12;
                                        QtyBase1 := QtyBase / BarcodeRec.Quantity;
                                    END;
                                END ELSE BEGIN
                                    QtyBase := BarcodeRec.Quantity * BarcodeRec."Quantity Per";
                                    QtyBase1 := QtyBase / BarcodeRec.Quantity;
                                END;
                                //Split Logic in case of MRP Change +
                                SaLnInsertRec.RESET;
                                SaLnInsertRec.SETRANGE("Document Type", "Document Type");
                                SaLnInsertRec.SETRANGE("Document No.", "No.");
                                SaLnInsertRec.SETRANGE(Type, SaLnInsertRec.Type::Item);
                                SaLnInsertRec.SETRANGE("No.", BarcodeRec."Item Code");
                                SaLnInsertRec.SETRANGE("Variant Code", BarcodeRec."Variant Code");
                                SaLnInsertRec.SETRANGE("MRP Price", BarcodeMRP);
                                //SaLnInsertRec.SETRANGE("Copied To New ORder","Copied to New Order");
                                SaLnInsertRec.SETFILTER(SaLnInsertRec."Outstanding Quantity", '<>%1', 0);
                                IF SaLnInsertRec.FINDFIRST THEN BEGIN
                                    REPEAT
                                        IF SaLnInsertRec."Outstanding Quantity" - SaLnInsertRec."Qty. to Ship" <> 0 THEN BEGIN
                                            IF ((SaLnInsertRec."Outstanding Quantity" - SaLnInsertRec."Qty. to Ship") <= QtyBase1) THEN BEGIN
                                                QtytoShipNew := SaLnInsertRec."Qty. to Ship";//FC 180423
                                                SaLnInsertRec.VALIDATE(Quantity, SaLnInsertRec.Quantity + QtyBase1);
                                                SaLnInsertRec.VALIDATE("Qty. to Ship", QtytoShipNew); //FC 180423
                                                QtytoShipNew := 0; //FC 180423

                                                QtytoShipNew := SalesLineRecord."Qty. to Ship"; //FC 180423
                                                SalesLineRecord.VALIDATE(Quantity, SalesLineRecord.Quantity - QtyBase1);
                                                SalesLineRecord.VALIDATE("Qty. to Ship", QtytoShipNew); //FC 180423
                                                QtytoShipNew := 0; //FC 180423
                                                SalesLineRecord.MODIFY(TRUE);
                                            END;
                                            IF SaLnInsertRec."Quantity (Base)" - (SaLnInsertRec."Qty. to Ship (Base)" + SaLnInsertRec."Qty. Shipped (Base)") > 0 THEN BEGIN
                                                UsedQty := (SaLnInsertRec."Quantity (Base)" - (SaLnInsertRec."Qty. to Ship (Base)" + SaLnInsertRec."Qty. Shipped (Base)"));
                                                IF QtyToShip - (SaLnInsertRec."Quantity (Base)" - (SaLnInsertRec."Qty. to Ship (Base)" + SaLnInsertRec."Qty. Shipped (Base)")) > 0 THEN BEGIN
                                                    //SaLnInsertRec.VALIDATE(SaLnInsertRec."Qty. to Ship (Base)",
                                                    //SaLnInsertRec.Quantity(base) - SaLnInsertRec."Qty. Shipped (Base)");

                                                    SaLnInsertRec.VALIDATE("Qty. to Ship", SaLnInsertRec.Quantity - SaLnInsertRec."Quantity Shipped");

                                                    SaLnInsertRec.VALIDATE("Box Counter", SaLnInsertRec."Box Counter" + 1); //FC 040217

                                                    SaLnInsertRec.MODIFY;
                                                    BarcodeRec."Blanket Order Line No." := SaLnInsertRec."Line No.";
                                                    SaLnInsertRec.MARK(TRUE);
                                                    QtyToShip := QtyToShip - UsedQty;
                                                    Flg := TRUE;
                                                END ELSE BEGIN
                                                    //SaLnInsertRec.VALIDATE(SaLnInsertRec."Qty. to Ship (Base)",QtyToShip+SaLnInsertRec."Qty. to Ship (Base)");
                                                    //SaLnInsertRec.MODIFY;
                                                    SaLnInsertRec.VALIDATE("Qty. to Ship", (QtyToShip / SaLnInsertRec."Qty. per Unit of Measure") + SaLnInsertRec."Qty. to Ship");
                                                    SaLnInsertRec.VALIDATE("Box Counter", SaLnInsertRec."Box Counter" + 1); //FC 040217
                                                    SaLnInsertRec.MODIFY;

                                                    BarcodeRec."Blanket Order Line No." := SaLnInsertRec."Line No.";
                                                    SaLnInsertRec.MARK(TRUE);
                                                    QtyToShip := 0;
                                                    Flg := TRUE;
                                                END;
                                            END;
                                            LastSalesLineNo := SaLnInsertRec."Line No.";
                                            SplitFlg := TRUE;
                                            SaLnInsertRec.MODIFY(TRUE);
                                            BarcodeRec.MODIFY(TRUE); //FC Nida 16052014
                                        END;
                                    UNTIL SaLnInsertRec.NEXT = 0;


                                    //FC Nida 13/Apr/2014 +
                                    IF SplitFlg = FALSE THEN BEGIN
                                        SaLnInsertRec.RESET;
                                        SaLnInsertRec.SETRANGE("Document Type", "Document Type");
                                        SaLnInsertRec.SETRANGE("Document No.", "No.");
                                        SaLnInsertRec.SETRANGE(Type, SaLnInsertRec.Type::Item);
                                        SaLnInsertRec.SETRANGE("No.", BarcodeRec."Item Code");
                                        SaLnInsertRec.SETRANGE("Variant Code", BarcodeRec."Variant Code");
                                        SaLnInsertRec.SETRANGE("MRP Price", SalesLineRecord."MRP Price");
                                        SaLnInsertRec.SETFILTER("Outstanding Quantity", '<>%1', 0);
                                        IF SaLnInsertRec.FINDFIRST THEN BEGIN
                                            //BarcodeMRP :=BarcodeRec.MRP*12;
                                            //PBS PA 030816
                                            IF SalesLineRecord."Unit of Measure Code" = 'DOZ' THEN BEGIN
                                                BarcodeMRP := BarcodeRec.MRP * 12;
                                            END ELSE BEGIN
                                                BarcodeMRP := BarcodeRec.MRP;
                                            END;
                                            //PBS PA 030816
                                            BarcodeCustPriceGroupCode := GetCustomerPriceGroupBarcode(BarcodeRec."Item Code", BarcodeRec."Variant Code",
                                            SalesLineRecord."Unit of Measure Code", CustomerPriceGroupCode + '|' + CustomerPriceGroupCodeOld + '|' + CustomerPriceGroupCodetemp, BarcodeMRP);
                                            IF BarcodeCustPriceGroupCode = '' THEN BEGIN
                                                ErrorText := 'Customer Price Group Not define in Sales Price ';
                                                BarcodeRec."Parent Serial No." := '';
                                                BarcodeRec.MODIFY;
                                                EXIT(FALSE);
                                            END;
                                            //PBS MAN 170918
                                            AvailableSalesline.RESET;
                                            AvailableSalesline.SETRANGE("Document Type", AvailableSalesline."Document Type"::Order);
                                            AvailableSalesline.SETRANGE("Document No.", "No.");
                                            AvailableSalesline.SETRANGE(Type, AvailableSalesline.Type::Item);
                                            AvailableSalesline.SETRANGE("No.", BarcodeRec."Item Code");
                                            AvailableSalesline.SETRANGE("Variant Code", BarcodeRec."Variant Code");
                                            AvailableSalesline.SETRANGE("Split Base Line No.", SalesLineRecord."Line No.");
                                            AvailableSalesline.SETRANGE("Copied to New Order", SalesLineRecord."Copied to New Order");
                                            IF NOT AvailableSalesline.FIND('-') THEN BEGIN
                                                LastSalesLineNo += 10000;
                                                SalesLineInsertRec.INIT;
                                                SalesLineInsertRec.VALIDATE("Document Type", SalesLineInsertRec."Document Type"::Order);
                                                SalesLineInsertRec.VALIDATE("Document No.", "No.");
                                                SalesLineInsertRec.VALIDATE("Line No.", LastSalesLineNo);
                                                SalesLineInsertRec.VALIDATE(Type, SalesLineInsertRec.Type::Item);
                                                SalesLineInsertRec.VALIDATE("No.", BarcodeRec."Item Code");
                                                SalesLineInsertRec.VALIDATE("Variant Code", BarcodeRec."Variant Code");
                                                QtytoShipNew := SalesLineInsertRec."Qty. to Ship"; //FC 180423
                                                SalesLineInsertRec.VALIDATE(Quantity, QtyBase1);
                                                SalesLineInsertRec.VALIDATE("Qty. to Ship", QtytoShipNew); // FC 180423
                                                QtytoShipNew := 0;// FC 180423

                                                SalesLineInsertRec.VALIDATE("Split Base Line No.", SalesLineRecord."Line No.");
                                                SalesLineInsertRec.VALIDATE("Copied to New Order", SalesLineRecord."Copied to New Order");
                                                SalesLineInsertRec.INSERT(TRUE);

                                                SalesLineInsertRec.VALIDATE("Customer Price Group", BarcodeCustPriceGroupCode);
                                                SalesLineInsertRec."Order Date" := SalesLineRecord."Order Date";
                                                SalesLineInsertRec.MODIFY(TRUE);

                                                QtytoShipNew := SalesLineRecord."Qty. to Ship"; //Fc 180423
                                                SalesLineRecord.VALIDATE(Quantity, SalesLineRecord.Quantity - QtyBase1);
                                                SalesLineRecord.VALIDATE("Qty. to Ship", QtytoShipNew); // FC 180423
                                                QtytoShipNew := 0;// FC 180423

                                                SalesLineRecord.VALIDATE("Split Base Line No.", LastSalesLineNo);
                                                //SalesLineRecord.VALIDATE("Copied to New Order",SalesLineRecord."Copied to New Order");
                                                SalesLineRecord.MODIFY(TRUE);
                                            END ELSE BEGIN
                                                SalesLineInsertRec.RESET;
                                                SalesLineInsertRec.GET(AvailableSalesline."Document Type", AvailableSalesline."Document No.", AvailableSalesline."Line No.");
                                                QtytoShipNew := SalesLineInsertRec."Qty. to Ship";//FC 180423
                                                SalesLineInsertRec.VALIDATE(Quantity, SalesLineInsertRec.Quantity + QtyBase1);
                                                SalesLineInsertRec.VALIDATE("Qty. to Ship", QtytoShipNew); //FC 180423
                                                QtytoShipNew := 0; //FC 180423
                                                SalesLineInsertRec.MODIFY(TRUE);
                                                LastSalesLineNo := SalesLineInsertRec."Line No.";
                                                QtytoShipNew := SalesLineRecord."Qty. to Ship";//FC 180423
                                                SalesLineRecord.VALIDATE(Quantity, SalesLineRecord.Quantity - QtyBase1);
                                                SalesLineRecord.VALIDATE("Qty. to Ship", QtytoShipNew); //FC 180423
                                                QtytoShipNew := 0;//FC 180423
                                                SalesLineRecord.MODIFY(TRUE);
                                            END;
                                            //PBS MAN 170918


                                            IF SalesLineInsertRec."Outstanding Quantity" - SalesLineInsertRec."Qty. to Ship" <> 0 THEN
                                                IF SalesLineInsertRec."Quantity (Base)" - (SalesLineInsertRec."Qty. to Ship (Base)" + SalesLineInsertRec."Qty. Shipped (Base)") > 0 THEN BEGIN
                                                    UsedQty := (SalesLineInsertRec."Quantity (Base)" - (SalesLineInsertRec."Qty. to Ship (Base)" +
                                                    SalesLineInsertRec."Qty. Shipped (Base)"));
                                                    IF QtyToShip - (SalesLineInsertRec."Quantity (Base)" - (SalesLineInsertRec."Qty. to Ship (Base)" + SalesLineInsertRec."Qty. Shipped (Base)")) > 0 THEN BEGIN
                                                        //SalesLineInsertRec.VALIDATE(SalesLineInsertRec."Qty. to Ship (Base)",
                                                        //SalesLineInsertRec.Quantity - SalesLineInsertRec."Qty. Shipped (Base)");
                                                        SalesLineInsertRec.VALIDATE("Qty. to Ship", SalesLineInsertRec.Quantity - SalesLineInsertRec."Quantity Shipped");
                                                        SalesLineInsertRec.VALIDATE("Box Counter", SalesLineInsertRec."Box Counter" + 1); //FC 040217

                                                        SalesLineInsertRec.MODIFY;
                                                        BarcodeRec."Blanket Order Line No." := SalesLineInsertRec."Line No.";
                                                        SalesLineInsertRec.MARK(TRUE);
                                                        QtyToShip := QtyToShip - UsedQty;
                                                        Flg := TRUE;
                                                    END ELSE BEGIN
                                                        //SalesLineInsertRec.VALIDATE(SalesLineInsertRec."Qty. to Ship (Base)",QtyToShip+
                                                        //SalesLineInsertRec."Qty. to Ship (Base)");
                                                        SalesLineInsertRec.VALIDATE("Qty. to Ship", (QtyToShip / SalesLineInsertRec."Qty. per Unit of Measure") + SalesLineInsertRec."Qty. to Ship");
                                                        SalesLineInsertRec.VALIDATE("Box Counter", SalesLineInsertRec."Box Counter" + 1); //FC 040217

                                                        SalesLineInsertRec.MODIFY;
                                                        BarcodeRec."Blanket Order Line No." := SalesLineInsertRec."Line No.";
                                                        SalesLineInsertRec.MARK(TRUE);
                                                        QtyToShip := 0;
                                                        Flg := TRUE;
                                                    END;
                                                END;
                                            SplitFlg := TRUE;
                                        END;
                                    END;
                                    //Split Logic in case of MRP Change -
                                    //FC Nida 13/Apr/2014 -
                                END ELSE BEGIN // Check MRP ELSE
                                               //BarcodeMRP :=BarcodeRec.MRP*12;
                                               //PBS PA 030816
                                    IF SalesLineRecord."Unit of Measure Code" = 'DOZ' THEN BEGIN
                                        BarcodeMRP := BarcodeRec.MRP * 12;
                                    END ELSE BEGIN
                                        BarcodeMRP := BarcodeRec.MRP;
                                    END;
                                    //PBS PA 030816
                                    BarcodeCustPriceGroupCode := GetCustomerPriceGroupBarcode(BarcodeRec."Item Code", BarcodeRec."Variant Code",
                                    SalesLineRecord."Unit of Measure Code", CustomerPriceGroupCode + '|' + CustomerPriceGroupCodeOld + '|' + CustomerPriceGroupCodetemp, BarcodeMRP);
                                    IF BarcodeCustPriceGroupCode = '' THEN BEGIN
                                        ErrorText := 'Customer Price Group Not define in Sales Price ';
                                        BarcodeRec."Parent Serial No." := '';
                                        BarcodeRec.MODIFY;
                                        EXIT(FALSE);
                                    END;
                                    //PBS MAN 170918
                                    AvailableSalesline.RESET;
                                    AvailableSalesline.SETRANGE("Document Type", AvailableSalesline."Document Type"::Order);
                                    AvailableSalesline.SETRANGE("Document No.", "No.");
                                    AvailableSalesline.SETRANGE(Type, AvailableSalesline.Type::Item);
                                    AvailableSalesline.SETRANGE("No.", BarcodeRec."Item Code");
                                    AvailableSalesline.SETRANGE("Variant Code", BarcodeRec."Variant Code");
                                    AvailableSalesline.SETRANGE("Split Base Line No.", SalesLineRecord."Line No.");
                                    AvailableSalesline.SETRANGE("Copied to New Order", SalesLineRecord."Copied to New Order");
                                    IF NOT AvailableSalesline.FIND('-') THEN BEGIN
                                        LastSalesLineNo += 10000;
                                        SalesLineInsertRec.INIT;
                                        SalesLineInsertRec.VALIDATE("Document Type", SalesLineInsertRec."Document Type"::Order);
                                        SalesLineInsertRec.VALIDATE("Document No.", "No.");
                                        SalesLineInsertRec.VALIDATE("Line No.", LastSalesLineNo);
                                        SalesLineInsertRec.VALIDATE(Type, SalesLineInsertRec.Type::Item);
                                        SalesLineInsertRec.VALIDATE("No.", BarcodeRec."Item Code");
                                        SalesLineInsertRec.VALIDATE("Variant Code", BarcodeRec."Variant Code");
                                        QtytoShipNew := SalesLineInsertRec."Qty. to Ship"; //FC 180423
                                        SalesLineInsertRec.VALIDATE(Quantity, QtyBase1);
                                        SalesLineInsertRec.VALIDATE("Qty. to Ship", QtytoShipNew); //FC 180423
                                        QtytoShipNew := 0; // FC 180423

                                        SalesLineInsertRec.VALIDATE("Split Base Line No.", SalesLineRecord."Line No.");
                                        SalesLineInsertRec.VALIDATE("Copied to New Order", SalesLineRecord."Copied to New Order");
                                        SalesLineInsertRec.INSERT(TRUE);

                                        SalesLineInsertRec.VALIDATE("Customer Price Group", BarcodeCustPriceGroupCode);
                                        SalesLineInsertRec.VALIDATE("Order Date", SalesLineRecord."Order Date");
                                        SalesLineInsertRec.MODIFY(TRUE);
                                        QtytoShipNew := SalesLineRecord."Qty. to Ship"; //FC 180423
                                        SalesLineRecord.VALIDATE(Quantity, SalesLineRecord.Quantity - QtyBase1);
                                        SalesLineRecord.VALIDATE("Qty. to Ship", QtytoShipNew);//FC 180423
                                        QtytoShipNew := 0;//FC 180423
                                        SalesLineRecord.VALIDATE("Split Base Line No.", LastSalesLineNo);
                                        SalesLineRecord.MODIFY(TRUE);
                                    END ELSE BEGIN
                                        SalesLineInsertRec.RESET;
                                        SalesLineInsertRec.GET(AvailableSalesline."Document Type", AvailableSalesline."Document No.", AvailableSalesline."Line No.");
                                        QtytoShipNew := SalesLineInsertRec."Qty. to Ship"; //FC 180423
                                        SalesLineInsertRec.VALIDATE(Quantity, SalesLineInsertRec.Quantity + QtyBase1);
                                        SalesLineInsertRec.VALIDATE("Qty. to Ship", QtytoShipNew); //FC 180423
                                        QtytoShipNew := 0; //FC 180423

                                        LastSalesLineNo := SalesLineInsertRec."Line No.";
                                        QtytoShipNew := SalesLineRecord."Qty. to Ship"; //FC 180423
                                        SalesLineRecord.VALIDATE(Quantity, SalesLineRecord.Quantity - QtyBase1);
                                        SalesLineRecord.VALIDATE("Qty. to Ship", QtytoShipNew); //FC 180423
                                        QtytoShipNew := 0; //FC 180423
                                        SalesLineInsertRec.MODIFY(TRUE);
                                        SalesLineRecord.MODIFY(TRUE);
                                    END;
                                    //PBS MAN 170918



                                    IF SalesLineInsertRec."Outstanding Quantity" - SalesLineInsertRec."Qty. to Ship" <> 0 THEN
                                        IF SalesLineInsertRec."Quantity (Base)" - (SalesLineInsertRec."Qty. to Ship (Base)" + SalesLineInsertRec."Qty. Shipped (Base)") > 0 THEN BEGIN
                                            UsedQty := (SalesLineInsertRec."Quantity (Base)" - (SalesLineInsertRec."Qty. to Ship (Base)" + SalesLineInsertRec."Qty. Shipped (Base)"));
                                            IF QtyToShip - (SalesLineInsertRec."Quantity (Base)" -
                                            (SalesLineInsertRec."Qty. to Ship (Base)" + SalesLineInsertRec."Qty. Shipped (Base)")) > 0 THEN BEGIN
                                                //SalesLineInsertRec.VALIDATE(SalesLineInsertRec."Qty. to Ship (Base)",
                                                //SalesLineInsertRec.Quantity - SalesLineInsertRec."Qty. Shipped (Base)");
                                                SalesLineInsertRec.VALIDATE("Qty. to Ship", SalesLineInsertRec.Quantity - SalesLineInsertRec."Quantity Shipped");
                                                SalesLineInsertRec.VALIDATE("Box Counter", SalesLineInsertRec."Box Counter" + 1); //FC 040217

                                                SalesLineInsertRec.MODIFY;
                                                BarcodeRec."Blanket Order Line No." := SalesLineInsertRec."Line No.";
                                                SalesLineInsertRec.MARK(TRUE);
                                                QtyToShip := QtyToShip - UsedQty;
                                                Flg := TRUE;
                                            END ELSE BEGIN
                                                //SalesLineInsertRec.VALIDATE(SalesLineInsertRec."Qty. to Ship (Base)",QtyToShip+
                                                //SalesLineInsertRec."Qty. to Ship (Base)");
                                                SalesLineInsertRec.VALIDATE("Qty. to Ship", (QtyToShip / SalesLineInsertRec."Qty. per Unit of Measure") + SalesLineInsertRec."Qty. to Ship");
                                                SalesLineInsertRec.VALIDATE("Box Counter", SalesLineInsertRec."Box Counter" + 1);   //FC 040217

                                                SalesLineInsertRec.MODIFY;
                                                BarcodeRec."Blanket Order Line No." := SalesLineInsertRec."Line No.";
                                                SalesLineInsertRec.MARK(TRUE);
                                                QtyToShip := 0;
                                                Flg := TRUE;
                                            END;
                                        END;
                                    SplitFlg := TRUE;
                                END;
                            END ELSE BEGIN //Pick Qty Check ELSE
                                           //ErrorText := 'qtytpship '+FORMAT(QtyToShip)+' and usedqty'+FORMAT(UsedQty);
                                           //EXIT(FALSE);

                                IF SalesLineRecord."Outstanding Quantity" - SalesLineRecord."Qty. to Ship" <> 0 THEN
                                    IF SalesLineRecord."Quantity (Base)" - (SalesLineRecord."Qty. to Ship (Base)" + SalesLineRecord."Qty. Shipped (Base)") > 0 THEN BEGIN
                                        UsedQty := (SalesLineRecord."Quantity (Base)" - (SalesLineRecord."Qty. to Ship (Base)" +
                                        SalesLineRecord."Qty. Shipped (Base)"));
                                        IF QtyToShip - (SalesLineRecord."Quantity (Base)" - (SalesLineRecord."Qty. to Ship (Base)" + SalesLineRecord."Qty. Shipped (Base)")) > 0 THEN BEGIN
                                            SalesLineRecord.VALIDATE("Qty. to Ship (Base)", SalesLineRecord.Quantity - SalesLineRecord."Qty. Shipped (Base)");
                                            SalesLineRecord.VALIDATE("Box Counter", SalesLineRecord."Box Counter" + 1);   //FC 040217
                                            SalesLineRecord.MODIFY;

                                            BarcodeRec."Blanket Order Line No." := SalesLineRecord."Line No.";
                                            SalesLineRecord.MARK(TRUE);
                                            QtyToShip := QtyToShip - UsedQty;
                                            Flg := TRUE;
                                        END ELSE BEGIN
                                            IF SalesLineRecord."Qty. per Unit of Measure" = 1 THEN BEGIN //PBS PA 290716
                                                SalesLineRecord.VALIDATE("Qty. to Ship (Base)", QtyToShip + SalesLineRecord."Qty. to Ship (Base)");
                                                SalesLineRecord.VALIDATE("Box Counter", SalesLineRecord."Box Counter" + 1); //FC 040217

                                            END ELSE BEGIN
                                                SalesLineRecord.VALIDATE("Qty. to Ship", ((QtyToShip + SalesLineRecord."Qty. to Ship (Base)") / SalesLineRecord."Qty. per Unit of Measure"));
                                                SalesLineRecord.VALIDATE("Box Counter", SalesLineRecord."Box Counter" + 1);   //FC 040217
                                            END;
                                            SalesLineRecord.MODIFY;

                                            BarcodeRec."Blanket Order Line No." := SalesLineRecord."Line No.";
                                            SalesLineRecord.MARK(TRUE);
                                            QtyToShip := 0;
                                            Flg := TRUE;
                                        END;
                                    END;
                            END;
                            //Create Pick List Code +
                            IF (Flg = TRUE) THEN BEGIN

                                PickListRec.RESET;
                                PickListRec.SETRANGE("Activity Type", PickListRec."Activity Type"::"Invt. Pick");
                                PickListRec.SETRANGE("No.", ParentBarcode);
                                IF PickListRec.FINDLAST THEN
                                    LineNo := PickListRec."Line No." + 10000
                                ELSE
                                    LineNo := 10000;
                                //IF (SalesLineRecord."Qty. to Ship"-SalesLineRecord."Outstanding Quantity")>0 THEN BEGIN //Asmawai.Start
                                //IF (SalesLineRecord."Outstanding Quantity"-SalesLineRecord."Qty. to Ship")>0 THEN BEGIN //Asmawai.Start

                                PickListRec.RESET; //FC MIL 220815
                                PickListRec.SETRANGE("Activity Type", PickListRec."Activity Type"::"Invt. Pick");//FC MIL 220815
                                PickListRec.SETRANGE(ItemBarcode, ItemBarcode); //FC MIL 220815
                                IF NOT PickListRec.FINDFIRST THEN BEGIN //FC MIL 220815
                                    PickListRec.INIT;
                                    PickListRec.VALIDATE("Activity Type", PickListRec."Activity Type"::"Invt. Pick");
                                    PickListRec.VALIDATE("No.", ParentCodeG);
                                    PickListRec.VALIDATE("Line No.", LineNo);
                                    PickListRec.VALIDATE("Source Type", 37);
                                    PickListRec.VALIDATE("Source Subtype", 1);
                                    PickListRec.VALIDATE("Source No.", "No.");

                                    IF SplitFlg = TRUE THEN
                                        PickListRec.VALIDATE("Source Line No.", LastSalesLineNo)
                                    ELSE
                                        PickListRec.VALIDATE("Source Line No.", SalesLineRecord."Line No.");

                                    PickListRec.VALIDATE("Source Document", PickListRec."Source Document"::"Sales Order");
                                    PickListRec.VALIDATE("Location Code", SalesLineRecord."Location Code");
                                    PickListRec.VALIDATE("Item No.", SalesLineRecord."No.");
                                    PickListRec.VALIDATE("Variant Code", SalesLineRecord."Variant Code");
                                    PickListRec.VALIDATE(ItemBarcode, ItemBarcode);
                                    PickListRec.VALIDATE("Unit of Measure Code", SalesLineRecord."Unit of Measure Code");
                                    //PBS MAN 151216 UOM Change
                                    //QtyBase :=BarcodeRec.Quantity * BarcodeRec."Quantity Per";
                                    IF BarcodeRec."Base Unit of Measure" = 'DOZ' THEN BEGIN
                                        QtyBase := BarcodeRec."Quantity (Base)" * 12;//PBS MAN 151216 UOM Change
                                    END ELSE BEGIN
                                        QtyBase := BarcodeRec."Quantity (Base)";//PBS MAN 151216 UOM Change
                                    END;
                                    //QtyBase1 := QtyBase / BarcodeRec.Quantity; //PBS MAN 151216 UOM Change
                                    QtyBase1 := QtyBase;  //PBS MAN 151216 UOM Change
                                                          //PBS MAN 151216 UOM Change
                                    IF PickListRec."Qty. per Unit of Measure" = 1 THEN BEGIN //PBS PA 290716
                                        PickListRec.VALIDATE(Quantity, QtyBase1);
                                        PickListRec.VALIDATE("Qty. Outstanding", QtyBase1);
                                        PickListRec.VALIDATE("Qty. (Base)", QtyBase1);
                                    END ELSE BEGIN
                                        PickListRec.VALIDATE(Quantity, (QtyBase1 / PickListRec."Qty. per Unit of Measure")); //PBS PA 290716
                                    END;
                                    PickListRec.VALIDATE("Carton Packed By", CurrUserID);
                                    PickListRec.INSERT(TRUE);
                                    PickListRec.MARK(TRUE);
                                END;//FC MIL 220815
                                    // END;//Asmawai.End
                            END;
                            //Create Pick List Code -
                        END; // Pick Qrty Condition END
                    UNTIL (SalesLineRecord.NEXT = 0) OR (QtyToShip = 0);

                IF QtyToShip <> 0 THEN BEGIN
                    ErrorText := 'Cannot ship this Item. QtyToShip is ' + Format(QtyToShip);
                    BarcodeRec."Parent Serial No." := '';
                    BarcodeRec.MODIFY;

                    PickListRec.RESET;
                    PickListRec.SETRANGE("Activity Type", PickListRec."Activity Type"::"Invt. Pick");
                    PickListRec.SETRANGE("No.", ParentCodeG);
                    PickListRec.SETRANGE(ItemBarcode, ItemBarcode);
                    IF PickListRec.FINDFIRST THEN
                        PickListRec.DELETE;

                    EXIT(FALSE);
                END ELSE
                    BarcodeRec."Process Barcode Buff Entry No" := BuffEntNo;
                BarcodeRec."Carton Packed By" := CurrUserID;
                BarcodeRec."Blanket Order No." := SalesLineRecord."Document No.";
                BarcodeRec."Bill to Customer No." := SalesLineRecord."Bill-to Customer No.";
                BarcodeRec."Sell to Customer No." := SalesLineRecord."Sell-to Customer No.";
                BarcodeRec.Status := BarcodeRec.Status::"Invoiced to Customer";
                BarcodeRec."Packed Date" := CURRENTDATETIME;
                if UpperCase(SalesLineRecord."Unit of Measure Code") = 'DOZ' then begin
                    BarcodeRec.WSP := SalesLineRecord."Unit Price" / 12;
                end else begin
                    BarcodeRec.WSP := SalesLineRecord."Unit Price";
                end;

                BarcodeRec.MODIFY;
                EXIT(TRUE);

            END; //IsRemoved
                 //**********************************************************************************************************



        //********************************** Unpacking *************************************************************
        IF IsRemoved THEN
            WITH SalesHeaderRec DO BEGIN
                IF SalesHeaderRec.Status <> 0 THEN BEGIN
                    ErrorText := 'Sales Order is realeased in ' + SalesHeaderRec."No.";
                    EXIT(FALSE);
                END;

                BarcodeRec.GET(ItemBarcode);
                QtyToShip := BarcodeRec."Quantity (Base)";
                OriginalQtyToShip := QtyToShip;
                Bsno.RESET;
                Bsno.SETRANGE(Bsno."Blanket Order No.", "No.");
                ParentCodeG := ParentBarcode;
                //BarcodeMRP :=BarcodeRec.MRP*12;
                BarcodeMRP := 0;

                CLEAR(SalesLineRecord);
                IF BarcodeRec."Blanket Order No." <> SalesHeaderRec."No." THEN BEGIN
                    ErrorText := 'This barcode does not belongs to Sales Order No. ' + SalesHeaderRec."No.";
                    EXIT(FALSE);
                END;
                SalesLineRecord.RESET;
                SalesLineRecord.SETRANGE("Document Type", "Document Type");
                SalesLineRecord.SETRANGE("Document No.", "No.");
                SalesLineRecord.SETRANGE(Type, SalesLineRecord.Type::Item);
                SalesLineRecord.SETRANGE("No.", BarcodeRec."Item Code");
                SalesLineRecord.SETRANGE("Variant Code", BarcodeRec."Variant Code");
                SalesLineRecord.SETFILTER("Qty. to Ship", '<>%1', 0);

                IF SalesLineRecord.FINDFIRST THEN
                    REPEAT
                        IF SalesLineRecord."Qty. to Ship (Base)" - QtyToShip < 0 THEN BEGIN
                            ErrorText := 'Cannot Remove this Item. Document No. ' + SalesLineRecord."Document No." + ' Line No. ' + format(SalesLineRecord."Line No.") + ' Item No. ' + SalesLineRecord."No." + ' Varient Code ' + SalesLineRecord."Variant Code";
                            ErrorText += '\ ''Qty. to Ship (Base)'' = ' + format(SalesLineRecord."Qty. to Ship (Base)") + ', QtyToShip = ' + Format(QtyToShip);
                            ;
                            EXIT(FALSE);
                        END;

                        //FC 290423 +
                        IF SalesLineRecord."Unit of Measure Code" = 'DOZ' THEN BEGIN
                            BarcodeMRP := BarcodeRec.MRP * 12;
                        END ELSE BEGIN
                            BarcodeMRP := BarcodeRec.MRP;
                        END;
                        //FC 290423 -

                        //New Code Pick List
                        PickListRec.RESET;
                        PickListRec.SETRANGE("Activity Type", PickListRec."Activity Type"::"Invt. Pick");
                        PickListRec.SETRANGE("No.", ParentCodeG);
                        PickListRec.SETRANGE(ItemBarcode, ItemBarcode);
                        i := PickListRec.COUNT;
                        IF PickListRec.FINDFIRST THEN
                            PickListRec.DELETE(TRUE);
                        //END New Code Pick List

                        //IF BarcodeRec.MRP <> GetNewMRP(BarcodeRec."Item Code",BarcodeRec."Variant Code","Customer Price Group") THEN BEGIN
                        IF BarcodeMRP <> SalesLineRecord."MRP Price" THEN BEGIN
                            //Sales Price
                            IF CustRec.GET("Sell-to Customer No.") THEN;
                            CustomerPriceGroupCodeOld := CustRec."Customer Price Group Old";
                            CustomerPriceGroupCodetemp := CustRec."Customer Price Group_Temp";
                            QtyBase := BarcodeRec.Quantity * BarcodeRec."Quantity Per";
                            QtyBase1 := QtyBase / BarcodeRec.Quantity;

                            SaLnInsertRec.RESET;
                            SaLnInsertRec.SETRANGE("Document Type", "Document Type");
                            SaLnInsertRec.SETRANGE("Document No.", "No.");
                            SaLnInsertRec.SETRANGE(Type, SaLnInsertRec.Type::Item);
                            SaLnInsertRec.SETRANGE("No.", BarcodeRec."Item Code");
                            SaLnInsertRec.SETRANGE("Variant Code", BarcodeRec."Variant Code");
                            //SaLnInsertRec.SETRANGE("Customer Price Group",CustomerPriceGroupCode);
                            SaLnInsertRec.SETRANGE("MRP Price", BarcodeMRP);
                            SaLnInsertRec.SETFILTER("Outstanding Quantity", '<>%1', 0);

                            IF SaLnInsertRec.FINDFIRST THEN
                                REPEAT
                                    if (SaLnInsertRec."Qty. per Unit of Measure" = 1) then begin //FC 290423
                                        SaLnInsertRec.VALIDATE("Qty. to Ship (Base)", SaLnInsertRec."Qty. to Ship (Base)" - QtyToShip);
                                        SaLnInsertRec.VALIDATE("Box Counter", SaLnInsertRec."Box Counter" + 1);   //FC 040217
                                    end else begin //FC 290423
                                        SaLnInsertRec.VALIDATE("Qty. to Ship", ((SaLnInsertRec."Qty. to Ship (Base)" - QtyToShip) / SaLnInsertRec."Qty. per Unit of Measure")); //FC 290423
                                        SaLnInsertRec.VALIDATE("Box Counter", SaLnInsertRec."Box Counter" + 1);   //FC 290423
                                    end;
                                    SaLnInsertRec.MODIFY(TRUE);
                                UNTIL SaLnInsertRec.NEXT = 0;

                        END ELSE BEGIN
                            if (SalesLineRecord."Qty. per Unit of Measure" = 1) then begin //FC 290423
                                SalesLineRecord.VALIDATE("Qty. to Ship (Base)", SalesLineRecord."Qty. to Ship (Base)" - QtyToShip);
                                SalesLineRecord.VALIDATE("Box Counter", SalesLineRecord."Box Counter" + 1);   //FC 040217
                            end else begin
                                SalesLineRecord.VALIDATE("Qty. to Ship", ((SalesLineRecord."Qty. to Ship (Base)" - QtyToShip) / SalesLineRecord."Qty. per Unit of Measure")); //FC 290423
                                SalesLineRecord.VALIDATE("Box Counter", SalesLineRecord."Box Counter" + 1);   //FC 290423
                            end;
                            SalesLineRecord.MODIFY;
                            SalesLineRecord.MARK(TRUE);


                        END;
                        QtyToShip := 0;
                    UNTIL (SalesLineRecord.NEXT = 0) OR (QtyToShip = 0);

                BarcodeRec."Parent Serial No." := '';
                BarcodeRec."Blanket Order No." := '';
                BarcodeRec."Blanket Order Line No." := 0;
                BarcodeRec."Carton Packed By" := '';
                BarcodeRec."Bill to Customer No." := '';
                BarcodeRec."Sell to Customer No." := '';
                //Mukesh BarcodeRec."Sell to Customer No." := '';
                BarcodeRec.Status := BarcodeRec.Status::Printed;

                BarcodeRec.MODIFY;
                PickListRec.RESET;
                PickListRec.SETRANGE("Activity Type", PickListRec."Activity Type"::"Invt. Pick");
                PickListRec.SETRANGE("No.", ParentCodeG);
                PickListRec.SETRANGE(ItemBarcode, ItemBarcode);
                IF PickListRec.FINDFIRST THEN
                    PickListRec.DELETE;

                IF QtyToShip <> 0 THEN BEGIN
                    //SalesLineRecord.ShipError(OriginalQtyToShip,BarcodeRec."Unit of Measure Code",OriginalQtyToShip-QtyToShip,QtyToShip)
                    ErrorText := 'Cannot ship this Item.';
                    EXIT(FALSE);
                END ELSE
                    EXIT(TRUE);
            END;
    end;

    procedure GetNewMRP_PBS(ItemCode: Code[20]; VarCode: Code[20]; CustomerPriceGroup: Code[20]; UnitofMeasureCode: Code[20]): Decimal
    var
        InventorySetupRec: Record "Inventory Setup";
        SalesPriceRec: Record "Sales Price";
    begin
        //PBS PA 030816
        InventorySetupRec.GET;
        SalesPriceRec.RESET;
        SalesPriceRec.SETRANGE(SalesPriceRec."Item No.", ItemCode);
        SalesPriceRec.SETRANGE(SalesPriceRec."Sales Type", SalesPriceRec."Sales Type"::"Customer Price Group");
        SalesPriceRec.SETRANGE(SalesPriceRec."Sales Code", CustomerPriceGroup);
        SalesPriceRec.SETRANGE(SalesPriceRec."Variant Code", VarCode);
        SalesPriceRec.SETRANGE(SalesPriceRec."Unit of Measure Code", UnitofMeasureCode);
        IF SalesPriceRec.FINDLAST THEN BEGIN
            EXIT(SalesPriceRec."MRP Price");
        END;
        //PBS PA 030816
    end;


    procedure GetCustomerPriceGroupBarcode(ItemNo: Code[20]; VariantCode: Code[20]; UOM: Code[20]; SalesCode: Code[50]; MRP: Decimal) SalesCodeRet: Code[20]
    var
        SalesPrcRec: Record "Sales Price";
    begin
        SalesPrcRec.RESET;
        SalesPrcRec.SETFILTER(SalesPrcRec."Item No.", '%1', ItemNo);
        SalesPrcRec.SETRANGE(SalesPrcRec."Variant Code", VariantCode);
        SalesPrcRec.SETRANGE(SalesPrcRec."Unit of Measure Code", UOM);
        SalesPrcRec.SETRANGE(SalesPrcRec."Sales Type", SalesPrcRec."Sales Type"::"Customer Price Group");
        //SalesPrcRec.SETRANGE(SalesPrcRec."Sales Code",SalesCode);
        SalesPrcRec.SETFILTER(SalesPrcRec."Sales Code", SalesCode);
        SalesPrcRec.SETRANGE(SalesPrcRec."MRP Price", MRP);
        IF SalesPrcRec.FINDFIRST THEN BEGIN
            SalesCodeRet := SalesPrcRec."Sales Code";
        END ELSE BEGIN
            SalesCodeRet := '';
        END;

        EXIT(SalesCodeRet);
    end;


    //**************************** ValidateDocumentNoProduction *******************************
    PROCEDURE ValidateDocumentNoProduction(inputJson: Text[2024]): Text[1024]
    var
        //Function In
        DocumentNo: Code[30];
        UID: Code[50];
        //Function Out
        DocNo: Code[30];
        ErrText: Text[250];
        flag: Boolean;
        input: JsonObject;
        c: JsonToken;
        Myresult: Text[1024];
        Orderjson: JsonObject;

    BEGIN
        ManuSetupRec.GET;

        input.ReadFrom(inputJson);
        //Get DocumentNo
        if input.Get('DocumentNo', c) then begin
            DocumentNo := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'DocumentNo Node not found in Payload');
            exit(Myresult);
        end;
        //Get UID
        if input.Get('UserID', c) then begin
            UID := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'UserID Node not found in Payload');
            exit(Myresult);
        end;


        IF NOT UserSetup.GET(UID) THEN BEGIN
            ErrText := UID + ' User ID not Found in User Setup Table ';
            //EXIT(FALSE);
            Myresult := CreateJsonPayload('0', 'False', ErrText);
            exit(Myresult);
        END;

        IF (DocumentNo = 'NEW') THEN BEGIN
            DocNo := NoSeriesMgt.GetNextNo('PROD', TODAY, TRUE);
            //EXIT(TRUE);
            Myresult := CreateJsonPayload('1', 'True', DocNo);
            exit(Myresult);
        END ELSE BEGIN
            ItemJournalLine.RESET;
            ItemJournalLine.SETCURRENTKEY("Production Barcode No");
            //ItemJournalLine.SETRANGE("Journal Template Name",,ManuSetupRec."Production Template Name");
            //ItemJournalLine.SETRANGE("Journal Batch Name",ManuSetupRec."Production Batch Name");
            ItemJournalLine.SETRANGE("Journal Template Name", UserSetup."Journal Template Name");
            ItemJournalLine.SETRANGE("Journal Batch Name", UserSetup."Journal Batch Name");

            ItemJournalLine.SETFILTER("Production Barcode No", DocumentNo);
            IF ItemJournalLine.FINDLAST THEN BEGIN
                DocNo := ItemJournalLine."Document No.";
                //EXIT(TRUE);
                Myresult := CreateJsonPayload('1', 'True', DocNo);
                exit(Myresult);
            END ELSE BEGIN
                ItemJournalLine.RESET;
                //ItemJournalLine.SETRANGE("Journal Template Name",ManuSetupRec."Production Template Name");
                //ItemJournalLine.SETRANGE("Journal Batch Name",ManuSetupRec."Production Batch Name");
                ItemJournalLine.SETRANGE("Journal Template Name", UserSetup."Journal Template Name");
                ItemJournalLine.SETRANGE("Journal Batch Name", UserSetup."Journal Batch Name");
                ItemJournalLine.SETCURRENTKEY("Document No.");
                ItemJournalLine.SETFILTER("Document No.", DocumentNo);
                IF ItemJournalLine.FINDFIRST THEN BEGIN
                    DocNo := DocumentNo;
                    ErrText := '';
                    //EXIT(TRUE);
                    Myresult := CreateJsonPayload('1', 'True', DocNo);
                    exit(Myresult);
                END ELSE BEGIN
                    ErrText := DocumentNo + ' Document Number Invalid';
                    //EXIT(FALSE);
                    Myresult := CreateJsonPayload('0', 'False', DocNo);
                    exit(Myresult);
                END;
            END;
        END;
    END;

    //**************************** ValidateSerialNo *******************************

    PROCEDURE ValidateSerialNo(inputJson: Text[2024]): Text[1024]
    var
        //Function In
        Srlno: Code[50];
        DocNo: Code[50];

        //Function Out
        ItemCode: Code[50];
        VariantCode: Code[50];
        Description: Text[50];
        UOM: Code[10];
        Qty: Decimal;
        QTYBase: Decimal;
        ErrText: Text[1024];
        flg: Boolean;

        ProdOrdH: Record 5405;
        MinusStr: Code[10];

        input: JsonObject;
        c: JsonToken;
        Myresult: Text[1024];
        Orderjson: JsonObject;


    BEGIN

        input.ReadFrom(inputJson);
        //Get Srlno
        if input.Get('Srlno', c) then begin
            Srlno := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'Srlno Node not found in Payload');
            exit(Myresult);
        end;

        //Get DocNo
        if input.Get('DocNo', c) then begin
            DocNo := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'DocNo Node not found in Payload');
            exit(Myresult);
        end;


        MinusStr := '';
        MinusStr := COPYSTR(Srlno, 1, 1);
        IF MinusStr = '-' THEN
            Srlno := DELSTR(Srlno, 1, 1);

        IF NOT (MinusStr = '-') THEN BEGIN
            IF BSNO.GET(Srlno) THEN BEGIN
                /*
                IF BSNO."Transfer Order No." <> '' THEN BEGIN
                    ERROR('Duplcate Barcode');
                END;
                */

                //IF (BSNO."Stock Take Document No." = DocNo) OR (BSNO.Status = BSNO.Status::"Sent to Store") THEN BEGIN
                IF (BSNO."Stock Take Document No." = DocNo) THEN BEGIN
                    ErrText := 'Selected Barcode is already count';
                    //EXIT(FALSE);
                    Myresult := CreateJsonPayload('0', 'False', ErrText);
                    exit(Myresult);
                END;
                //RSMIL100516/.......

                //mukesh
                /*
                IF (BSNO."Purchase Order No." = DocNo) OR (BSNO."Purchase Order No." <> '') THEN BEGIN
                    ErrText := 'Selected Barcode is already count PO No. ' + BSNO."Purchase Order No.";
                    EXIT(FALSE);
                END;
                */

                //IF BSNO."Phy. Lot No."<>'' THEN BEGIN
                IF BSNO.Tracking = 0 THEN BEGIN
                    ProdOrdH.RESET;
                    ProdOrdH.SETRANGE("Replan Ref. No.", BSNO."Phy. Lot No.");
                    IF ProdOrdH.FINDFIRST THEN BEGIN
                        IF NOT (BSNO."Creation Date" > 20210401D) THEN BEGIN
                            ErrText := 'As this item is already in the production order, please use the FG Manufacturing tab';
                            //EXIT(FALSE);
                            Myresult := CreateJsonPayload('0', 'False', ErrText);
                            exit(Myresult);
                        END;
                    END;
                END;
                //RSMIL100516/.......
                ItemCode := BSNO."Item Code";
                VariantCode := BSNO."Variant Code";
                Description := BSNO."Item Description";
                UOM := BSNO."Base Unit of Measure";
                Qty := BSNO.Quantity;
                QTYBase := BSNO."Quantity (Base)";
                ErrText := '';
                //EXIT(TRUE);

                //IF BSNO."Phy. Lot No."<>'' THEN BEGIN
                IF BSNO.Tracking = 0 THEN BEGIN
                    ProdOrdH.RESET;
                    ProdOrdH.SETRANGE("Replan Ref. No.", BSNO."Phy. Lot No.");

                    IF ProdOrdH.FINDFIRST THEN BEGIN
                        ErrText := 'As this item is already in the production order, please use the FG Manufacturing tab';
                        //EXIT(FALSE);
                        Myresult := CreateJsonPayload('0', 'False', ErrText);
                        exit(Myresult);

                    END;
                    //  EXIT(TRUE);
                END ELSE BEGIN
                    ErrText := Srlno + '  Barcode Not Found ';
                    //EXIT(FALSE);
                    Myresult := CreateJsonPayload('0', 'False', ErrText);
                    exit(Myresult);
                END;
            END ELSE BEGIN
                IF BSNO.GET(Srlno) THEN BEGIN
                    //IF (BSNO."Stock Take Document No." = DocNo) OR (BSNO.Status = BSNO.Status::"Sent to Store") THEN BEGIN

                    ItemCode := BSNO."Item Code";
                    VariantCode := BSNO."Variant Code";
                    Description := BSNO."Item Description";
                    UOM := BSNO."Base Unit of Measure";
                    Qty := BSNO.Quantity;
                    QTYBase := BSNO."Quantity (Base)";
                    ErrText := '';
                    //IF BSNO."Phy. Lot No."<>'' THEN BEGIN
                    IF BSNO."Transfer Order No." <> '' THEN BEGIN
                        //ERROR('Duplcate Barcode');
                        Myresult := CreateJsonPayload('0', 'False', 'Duplcate Barcode');
                        exit(Myresult);
                    END;
                    IF BSNO.Tracking = 0 THEN BEGIN
                        ProdOrdH.RESET;
                        ProdOrdH.SETRANGE("Replan Ref. No.", BSNO."Phy. Lot No.");
                        IF ProdOrdH.FINDFIRST THEN begin
                            ErrText := 'As this item is already in the production order, please use the FG Manufacturing tab';
                            //EXIT(FALSE);
                            Myresult := CreateJsonPayload('0', 'False', 'Duplcate Barcode');
                            exit(Myresult);
                        end;
                    END;

                    //EXIT(TRUE);

                END ELSE BEGIN
                    ErrText := Srlno + '  Barcode Not Found ';
                    //EXIT(FALSE);
                    Myresult := CreateJsonPayload('0', 'False', ErrText);
                    exit(Myresult);
                END;
            END;

        END;

        BSNO.RESET;
        MinusStr := '';
        MinusStr := COPYSTR(Srlno, 1, 1);
        IF MinusStr = '-' THEN
            Srlno := DELSTR(Srlno, 1, 1);

        IF NOT (MinusStr = '-') THEN BEGIN
            IF BSNO.GET(Srlno) THEN BEGIN
                //Mukesh
                //IF (BSNO."Stock Take Document No." = DocNo) OR (BSNO.Status = BSNO.Status::"Sent to Store") THEN BEGIN
                IF BSNO."Transfer Order No." <> '' THEN BEGIN
                    //ERROR('Duplcate Barcode');
                    Myresult := CreateJsonPayload('0', 'False', 'Duplcate Barcode');
                    exit(Myresult);
                END;
                IF (BSNO."Stock Take Document No." = DocNo) THEN BEGIN
                    ErrText := 'Selected Barcode is already count';
                    //EXIT(FALSE);
                    Myresult := CreateJsonPayload('0', 'False', ErrText);
                    exit(Myresult);
                END;

                ItemCode := BSNO."Item Code";
                VariantCode := BSNO."Variant Code";
                Description := BSNO."Item Description";
                UOM := BSNO."Base Unit of Measure";
                Qty := BSNO.Quantity;
                QTYBase := BSNO."Quantity (Base)";
                ErrText := '';
                //EXIT(TRUE);

            END ELSE BEGIN
                ErrText := Srlno + '  Barcode Not Found ';
                //EXIT(FALSE);
                Myresult := CreateJsonPayload('0', 'False', ErrText);
                exit(Myresult);
            END;
        END ELSE BEGIN
            IF BSNO.GET(Srlno) THEN BEGIN
                //mukesh
                //IF (BSNO."Stock Take Document No." = DocNo) OR (BSNO.Status = BSNO.Status::"Sent to Store") THEN BEGIN
                ItemCode := BSNO."Item Code";
                VariantCode := BSNO."Variant Code";
                Description := BSNO."Item Description";
                UOM := BSNO."Base Unit of Measure";
                Qty := BSNO.Quantity;
                QTYBase := BSNO."Quantity (Base)";
                ErrText := '';

                //EXIT(TRUE);

            END ELSE BEGIN
                ErrText := Srlno + '  Barcode Not Found ';
                //EXIT(FALSE);
                Myresult := CreateJsonPayload('0', 'False', ErrText);
                exit(Myresult);
            END;
        END;

        Clear(Orderjson);
        Orderjson.Add('id', '0');
        Orderjson.Add('Success', 'True');
        Orderjson.Add('ItemCode', ItemCode);
        Orderjson.Add('VariantCode', VariantCode);
        Orderjson.Add('Description', Description);
        Orderjson.Add('UOM', UOM);
        Orderjson.Add('Qty', Qty);
        Orderjson.Add('QTYBase', QTYBase);
        Orderjson.Add('Message', ErrText);
        Orderjson.WriteTo(Myresult);
        Myresult := Myresult.Replace('\', '');
        exit(Myresult);


    END;

    //*********************** ValidateDocBarcode*********************

    PROCEDURE ValidateDocBarcode(inputJson: Text[2024]): Text[1024]
    var
        //Function In
        DocBarcode: Code[30];
        UserID: Code[30];
        TemplateName: Code[10];
        BatchName: Code[10];
        DocNo: Code[30];
        flag: Boolean;

        //Function Out
        ErrText: Text[250];

        DocumentNo: Code[30];
        IJL: Record 83;
        MinusStr: Code[10];
        ItemRec: Record Item;

        input: JsonObject;
        c: JsonToken;
        Myresult: Text[1024];
        Orderjson: JsonObject;

    BEGIN

        input.ReadFrom(inputJson);
        //Get DocBarcode
        if input.Get('DocBarcode', c) then begin
            DocBarcode := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'Srlno Node not found in Payload');
            exit(Myresult);
        end;

        //Get UserID
        if input.Get('UserID', c) then begin
            UserID := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'UserID Node not found in Payload');
            exit(Myresult);
        end;

        //Get TemplateName
        if input.Get('TemplateName', c) then begin
            TemplateName := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'TemplateName Node not found in Payload');
            exit(Myresult);
        end;

        //Get BatchName
        if input.Get('BatchName', c) then begin
            BatchName := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'BatchName Node not found in Payload');
            exit(Myresult);
        end;

        //Get DocNo
        if input.Get('DocNo', c) then begin
            DocNo := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'DocNo Node not found in Payload');
            exit(Myresult);
        end;


        //PBS1.0 AA Temp use for IJL
        IF (TemplateName = '') OR (BatchName = '') THEN BEGIN
            ErrText := 'Template Name and Batch name in User Table is Blank';
            //EXIT(FALSE);
            Myresult := CreateJsonPayload('0', 'False', ErrText);
            exit(Myresult);
        END;


        ManuSetupRec.GET;
        UserSetup.GET(UserID);
        MinusStr := '';
        MinusStr := COPYSTR(DocBarcode, 1, 1);
        IF MinusStr = '-' THEN
            DocBarcode := DELSTR(DocBarcode, 1, 1);
        IF BSNO.GET(DocBarcode) THEN;


        IF UserSetup."Division Code" = '' THEN BEGIN
            ErrText := 'Division can not left blank. Please Enter in Usersetup ';
            //EXIT(FALSE);
            Myresult := CreateJsonPayload('0', 'False', ErrText);
            exit(Myresult);
        END;


        IF NOT (MinusStr = '-') THEN BEGIN
            IF BSNO.GET(DocBarcode) THEN BEGIN

                //AKK+ 20150402
                IF BSNO.Tracking <> 0 THEN begin
                    //ERROR('%1 Barcode is already exist in %2', BSNO."Serial No.", BSNO.Tracking);
                    ErrText := BSNO."Serial No." + ' Barcode is already exist in ' + format(BSNO.Tracking);
                    Myresult := CreateJsonPayload('0', 'False', ErrText);
                    exit(Myresult);
                End;
                //AKK- 20150402
                ItemJournalLineTemp.RESET;
                ItemJournalLineTemp.SETCURRENTKEY(ItemJournalLineTemp."Production Barcode No");
                //Sumit-Nida
                //ItemJournalLine.SETRANGE(ItemJournalLine."Journal Template Name",ManuSetupRec."Production Template Name");
                //ItemJournalLine.SETRANGE(ItemJournalLine."Journal Batch Name",ManuSetupRec."Production Batch Name");
                ItemJournalLineTemp.SETRANGE(ItemJournalLineTemp."Journal Template Name", TemplateName);
                ItemJournalLineTemp.SETRANGE(ItemJournalLineTemp."Journal Batch Name", BatchName);
                ItemJournalLineTemp.SETFILTER(ItemJournalLineTemp."Production Barcode No", DocBarcode);
                IF ItemJournalLineTemp.FINDFIRST THEN BEGIN
                    ErrText := BSNO."Serial No." + ' Barcode Already Exits ' + ItemJournalLineTemp."Document No.";
                    //ErrText := 'Selected Barcode is already exits in Item Journal Line';
                    //EXIT(FALSE);
                    Myresult := CreateJsonPayload('0', 'False', ErrText);
                    exit(Myresult);
                END;
            END ELSE BEGIN
                ErrText := DocBarcode + ' Barcode not Found in Barcode Serial No.';
                //EXIT(FALSE);
                Myresult := CreateJsonPayload('0', 'False', ErrText);
                exit(Myresult);
            END;
        END;
        IF (BSNO."Unit of Measure Code" <> 'BOX') THEN BEGIN
            ErrText := 'Only Box barcode can ship';
            //EXIT(FALSE);
            Myresult := CreateJsonPayload('0', 'False', ErrText);
            exit(Myresult);
        END;

        //IF (FORMAT(BSNO."Creation Date")<>'') THEN BEGIN
        //  ErrText := BSNO."Serial No." + ' Barcode Already Exits! Dated  ' + FORMAT(BSNO."Creation Date");
        //  EXIT(FALSE);
        //END;
        IF NOT (MinusStr = '-') THEN BEGIN
            RANDOMIZE();
            LastEntryNo := RANDOM(2147483647) + ActiveSession."Session ID";
            ItemJournalLineTemp.INIT;
            ItemJournalLineTemp.VALIDATE("Posting Date", TODAY);
            ItemJournalLineTemp.VALIDATE("Line No.", LastEntryNo + 1);
            ItemJournalLineTemp.VALIDATE(ItemJournalLineTemp."Item No.", BSNO."Item Code");
            ItemJournalLineTemp.VALIDATE(ItemJournalLineTemp."Variant Code", BSNO."Variant Code");



            //ItemJournalLineTemp.VALIDATE(ItemJournalLineTemp.Quantity,BSNO."Quantity (Base)");
            // FC MIL 06012015 ItemJournalLine.VALIDATE(ItemJournalLine."Location Code",'STORE');


            ItemJournalLineTemp.VALIDATE(ItemJournalLineTemp."Location Code", UserSetup."User Location");
            ItemJournalLineTemp.VALIDATE(ItemJournalLineTemp."Entry Type", ItemJournalLine."Entry Type"::"Positive Adjmt.");
            ItemJournalLineTemp.VALIDATE(ItemJournalLineTemp."Reason Code", 'PRODUCTION');
            ItemJournalLineTemp.VALIDATE(ItemJournalLineTemp."Production Barcode No", BSNO."Serial No.");
            //ItemJournalLine.VALIDATE(ItemJournalLine."Lot No.",BSno."Phy. Lot No.");
            ItemJournalLineTemp.VALIDATE(ItemJournalLineTemp."Phy. Lot No.", BSNO."Phy. Lot No.");
            //ItemJournalLine.VALIDATE(ItemJournalLine."Journal Template Name",ManuSetupRec."Production Template Name");
            //ItemJournalLine.VALIDATE(ItemJournalLine."Journal Batch Name",UserSetup."Production Batch Name");
            ItemJournalLineTemp.VALIDATE(ItemJournalLineTemp."Journal Template Name", TemplateName);
            ItemJournalLineTemp.VALIDATE(ItemJournalLineTemp."Journal Batch Name", BatchName);
            ItemJournalLineTemp.VALIDATE(ItemJournalLineTemp."Document No.", DocNo);
            //FC MIL 06012015 ItemJournalLine.VALIDATE(ItemJournalLine."Shortcut Dimension 1 Code",'D-30');
            ItemJournalLineTemp.VALIDATE(ItemJournalLineTemp."Shortcut Dimension 1 Code", UserSetup."Division Code");
            IF ItemRec.GET(BSNO."Item Code") THEN;
            ItemJournalLineTemp.VALIDATE("Unit of Measure Code", ItemRec."Sales Unit of Measure");

            IF (ItemRec."Sales Unit of Measure" = 'DOZ') AND (BSNO."Base Unit of Measure" = 'DOZ') THEN BEGIN
                ItemJournalLineTemp.VALIDATE(Quantity, BSNO."Quantity (Base)");

                //ItemJournalLineTemp.VALIDATE("Qty. to Ship", BSNO."Quantity (Base)");
            END ELSE
                IF (ItemRec."Sales Unit of Measure" = 'PCS') AND (BSNO."Base Unit of Measure" = 'PCS') THEN BEGIN
                    ItemJournalLineTemp.VALIDATE(Quantity, BSNO."Quantity (Base)");

                    //ItemJournalLineTemp.VALIDATE("Qty. to Ship", BSNO."Quantity (Base)");
                END ELSE
                    IF (ItemRec."Sales Unit of Measure" = 'DOZ') AND (BSNO."Base Unit of Measure" = 'PCS') THEN BEGIN
                        ItemJournalLineTemp.VALIDATE(Quantity, BSNO."Quantity (Base)" / 12);

                        //ItemJournalLineTemp.VALIDATE("Qty. to Ship", BSNO."Quantity (Base)"/12);
                    END;


            ItemJournalLineTemp.INSERT(TRUE);
            IF BarCodeSrno.GET(DocBarcode) THEN BEGIN
                BarCodeSrno.VALIDATE(BarCodeSrno.Status, BarCodeSrno.Status::"Sent to Store");
                BarCodeSrno.VALIDATE(BarCodeSrno."Output Date", TODAY);
                BarCodeSrno.VALIDATE("X Location", UserSetup."User Location");
                BarCodeSrno.Tracking := BarCodeSrno.Tracking::Production;
                //BarCodeSrno.VALIDATE(BarCodeSrno."Stock Take Document No.",'');
                BarCodeSrno.MODIFY(TRUE);
            END;
            IF GETLASTERRORTEXT <> '' THEN BEGIN
                ErrText := GETLASTERRORTEXT;
                //EXIT(FALSE);
                Myresult := CreateJsonPayload('0', 'False', ErrText);
                exit(Myresult);
            END ELSE BEGIN
                ErrText := '';
                //EXIT(TRUE);
                Myresult := CreateJsonPayload('1', 'True', ErrText);
                exit(Myresult);
            END;
        END ELSE BEGIN
            ItemJournalLineTemp.RESET;
            ItemJournalLineTemp.SETCURRENTKEY(ItemJournalLineTemp."Production Barcode No");
            ItemJournalLineTemp.SETRANGE(ItemJournalLineTemp."Production Barcode No", BSNO."Serial No.");
            IF ItemJournalLineTemp.FINDFIRST THEN
                ItemJournalLineTemp.DELETEALL(TRUE);
            IF BarCodeSrno.GET(DocBarcode) THEN BEGIN
                BarCodeSrno.VALIDATE(BarCodeSrno.Status, BarCodeSrno.Status::Printed);
                BarCodeSrno.VALIDATE(BarCodeSrno."Output Date", 0D);
                //BarCodeSrno.VALIDATE(BarCodeSrno."Stock Take Document No.",'');
                BarCodeSrno.VALIDATE(BarCodeSrno.Tracking, BarCodeSrno.Tracking::" ");
                BarCodeSrno.MODIFY(TRUE);
            END;
            IF GETLASTERRORTEXT <> '' THEN BEGIN
                ErrText := GETLASTERRORTEXT;
                //EXIT(FALSE);
                Myresult := CreateJsonPayload('0', 'False', ErrText);
                exit(Myresult);
            END ELSE BEGIN

                ErrText := '';
                //EXIT(TRUE);
                Myresult := CreateJsonPayload('1', 'True', ErrText);
                exit(Myresult);
            END;
        END;
        //PBS1.0 AA
    END;


    //*********************** ValidateUPBarcode *********************
    PROCEDURE ValidateUPBarcode(inputJson: Text[2024]): Text[1024]
    var
        //Function In
        Barcode: Text[30];
        //Function Out
        ErrText: Text[250];
        flag: Boolean;

        input: JsonObject;
        c: JsonToken;
        Myresult: Text[1024];
        Orderjson: JsonObject;

    BEGIN
        input.ReadFrom(inputJson);
        //Get Srlno
        if input.Get('Barcode', c) then begin
            Barcode := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'Barcode Node not found in Payload');
            exit(Myresult);
        end;


        BSNO.RESET;
        IF BSNO.GET(Barcode) THEN BEGIN
            IF BSNO."Blanket Order No." = '' THEN BEGIN
                ErrText := 'Carton Barcode is not assigned to any Sales Order';
                //EXIT(FALSE);
                Myresult := CreateJsonPayload('0', 'False', ErrText);
                exit(Myresult);

            END ELSE BEGIN
                ErrText := BSNO."Blanket Order No.";
                //EXIT(TRUE);
                Myresult := CreateJsonPayload('1', 'True', ErrText);
                exit(Myresult);
            END;
        END ELSE BEGIN
            ErrText := 'Selected Carton Barcode Does not exist';
            //EXIT(FALSE);
            Myresult := CreateJsonPayload('0', 'False', ErrText);
            exit(Myresult);
        END;
    END;

    //*********************** ValidateUCBarcode *********************
    PROCEDURE ValidateUCBarcode(inputJson: Text[2024]): Text[1024]
    var
        //Function In
        Barcode: Code[30];
        PBarcode: Code[30];
        OrderNo: Code[30];

        //Function Out
        ItemCode: Code[30];
        VariantCode: Code[30];
        UOM: Code[10];
        ItmCatalogCode: Code[30];
        ErrText: Text[250];
        flag: Boolean;

        input: JsonObject;
        c: JsonToken;
        Myresult: Text[1024];
        Orderjson: JsonObject;


    BEGIN
        //ItemCode,VariantCode,UOM,ItmCatalogCode,

        input.ReadFrom(inputJson);
        //Get Barcode
        if input.Get('Barcode', c) then begin
            Barcode := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'Barcode Node not found in Payload');
            exit(Myresult);
        end;

        //Get PBarcode
        if input.Get('PBarcode', c) then begin
            PBarcode := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'PBarcode Node not found in Payload');
            exit(Myresult);
        end;

        //Get OrderNo
        if input.Get('OrderNo', c) then begin
            OrderNo := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'OrderNo Node not found in Payload');
            exit(Myresult);
        end;


        BSNO.RESET;
        IF BSNO.GET(Barcode) THEN BEGIN
            IF BSNO."Parent Serial No." <> PBarcode THEN BEGIN
                ErrText := 'Selected Barcode - ' + Barcode + ' is NOT AVAILABLE inside the parent barcode. ' + BSNO."Parent Serial No." + ' - ' + BSNO."Blanket Order No." + '-' + OrderNo;
                ;
                //EXIT(FALSE);
                Myresult := CreateJsonPayload('0', 'False', ErrText);
                exit(Myresult);
            END ELSE BEGIN
                IF BSNO."Blanket Order No." <> OrderNo THEN BEGIN
                    ErrText := 'Selected Barcode ' + Barcode + ' is NOT AVAILABLE inside the parent barcode. ' + BSNO."Blanket Order No." + '-' + OrderNo;
                    //EXIT(FALSE);
                    Myresult := CreateJsonPayload('0', 'False', ErrText);
                    exit(Myresult);
                END ELSE BEGIN
                    ItemCode := BSNO."Item Code";
                    VariantCode := BSNO."Variant Code";
                    UOM := BSNO."Unit of Measure Code";
                    ItmCatalogCode := BSNO."Item Category Code";
                    //EXIT(TRUE);
                END;
            END;
        END ELSE BEGIN
            ErrText := 'Selected Barcode does not exists';
            //EXIT(FALSE);
            Myresult := CreateJsonPayload('0', 'False', ErrText);
            exit(Myresult);
        END;

        Orderjson.Add('id', '1');
        Orderjson.Add('Success', 'True');
        Orderjson.Add('Message', '');
        Orderjson.Add('ItemCode', ItemCode);
        Orderjson.Add('VariantCode', VariantCode);
        Orderjson.Add('UOM', UOM);
        Orderjson.Add('ItmCatalogCode', ItmCatalogCode);
        Orderjson.Add('ErrText', ErrText);
        Orderjson.WriteTo(Myresult);
        Myresult := Myresult.Replace('\', '');
        exit(Myresult);
    END;

    //*********************** BarcodeUnPacking *********************
    PROCEDURE BarcodeUnPacking(inputJson: Text[2024]): Text[1024]
    Var
        //Function In
        ChildBarcode: Code[30];
        ParentBarcode: Code[30];
        UserID: Code[30];

        //Function Out
        ErrText: Text[250];
        flag: Boolean;

        input: JsonObject;
        c: JsonToken;
        Myresult: Text[1024];
        Orderjson: JsonObject;
    BEGIN

        input.ReadFrom(inputJson);
        //Get ChildBarcode
        if input.Get('ChildBarcode', c) then begin
            ChildBarcode := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'ChildBarcode Node not found in Payload');
            exit(Myresult);
        end;

        //Get ParentBarcode
        if input.Get('ParentBarcode', c) then begin
            ParentBarcode := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'ParentBarcode Node not found in Payload');
            exit(Myresult);
        end;

        //Get UserID
        if input.Get('UserID', c) then begin
            UserID := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'UserID Node not found in Payload');
            exit(Myresult);
        end;


        if BSNO.GET(ChildBarcode) then begin
            if BSNO."Blanket Order No." = '' then begin
                ErrText := 'Blanket Order No. is blank in Barcode Serial No. Table for ChildBarcode ' + ChildBarcode + '.';
                Myresult := CreateJsonPayload('1', 'False', ErrText);
                exit(Myresult);
            end;
        end else begin
            ErrText := 'ChildBarcode ' + ChildBarcode + ' Does not exit ';
            Myresult := CreateJsonPayload('1', 'False', ErrText);
            exit(Myresult);
        end;

        if SalesHeaderRec.GET(SalesHeaderRec."Document Type"::Order, BSNO."Blanket Order No.") then begin
            IF NOT ShipTOBarcode(SalesHeaderRec, BSNO."Serial No.", ErrText, TRUE, 123, UserID, ParentBarcode) THEN BEGIN
                //EXIT(FALSE);
                Myresult := CreateJsonPayload('0', 'False', ErrText);
                exit(Myresult);
            END ELSE BEGIN
                //EXIT(TRUE);
                Myresult := CreateJsonPayload('1', 'True', ErrText);
                exit(Myresult);
            END;
        end else begin
            ErrText := 'Sales Order No. ' + BSNO."Blanket Order No." + ' Does not exit ';
            Myresult := CreateJsonPayload('1', 'False', ErrText);
            exit(Myresult);
        end;

    END;

    //*********************** ValidateUserPurchase *********************

    PROCEDURE ValidateUserPurch(inputJson: Text[2024]): Text[1024]
    var
        //Function In
        UserID: Text[30];
        //Function Out
        ProcessEnd: Text[30];
        ErrText: Text[250];
        UserName: Text[250];
        flg: Boolean;
        input: JsonObject;
        c: JsonToken;
        Myresult: Text[1024];
        Orderjson: JsonObject;
        PurchUserLocRec: Record "Purchase Header";
    BEGIN

        input.ReadFrom(inputJson);
        //Get UserID
        if input.Get('UserID', c) then begin
            UserID := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'UserID Node not found in Payload');
            exit(Myresult);
        end;

        UserSetup.RESET;
        IF UserSetup.GET(UserID) THEN BEGIN
            IF (UserSetup."User Location" <> '') THEN BEGIN
                UserName := UserSetup."User Name";
                ProcessEnd := UserSetup."Process Ending Barcode";
                //EXIT(TRUE);
                Orderjson.Add('id', '1');
                Orderjson.Add('Success', 'True');
                Orderjson.Add('Message', '');
                Orderjson.Add('UserName', UserName);
                Orderjson.Add('ProcessEnd', ProcessEnd);
                Orderjson.WriteTo(Myresult);
                Myresult := Myresult.Replace('\', '');
                exit(Myresult);

            END ELSE BEGIN
                ErrText := 'User location can not be blank';
                //EXIT(FALSE);
                Myresult := CreateJsonPayload('0', 'False', ErrText);
                exit(Myresult);
            END;
        END ELSE BEGIN
            //EXIT(FALSE);
            ProcessEnd := '';
            ErrText := 'Invalid User ID';
            Orderjson.Add('id', '0');
            Orderjson.Add('Success', 'False');
            Orderjson.Add('Message', '');
            Orderjson.Add('UserName', UserName);
            Orderjson.Add('ProcessEnd', ProcessEnd);
            Orderjson.WriteTo(Myresult);
            Myresult := Myresult.Replace('\', '');
            exit(Myresult);
        END;
    END;

    //*********************** ValidateDocNoPurch *********************
    PROCEDURE ValidateDocNoPurch(inputJson: Text[2024]): Text[1024]
    var
        //Function In
        DocumentNo: Code[30];
        UID: Code[50];
        //Function Out
        DocNo: Code[30];
        ErrText: Text[250];
        ErrText1: Text[250];
        flag: Boolean;

        input: JsonObject;
        c: JsonToken;
        Myresult: Text[1024];
        Orderjson: JsonObject;
        PH: Record "Purchase Header";
    BEGIN
        ManuSetupRec.GET;
        input.ReadFrom(inputJson);

        //Get DocumentNo
        if input.Get('DocumentNo', c) then begin
            DocumentNo := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'DocumentNo Node not found in Payload');
            exit(Myresult);
        end;

        //Get UID
        if input.Get('UserID', c) then begin
            UID := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'UserID Node not found in Payload');
            exit(Myresult);
        end;


        IF NOT UserSetup.GET(UID) THEN BEGIN
            ErrText := UID + ' User ID not Found in User Setup Table ';
            //EXIT(FALSE);
            Myresult := CreateJsonPayload('0', 'False', ErrText);
            exit(Myresult);
        END;

        IF (DocumentNo = 'NEW') THEN BEGIN
            DocNo := NoSeriesMgt.GetNextNo('PURC', TODAY, TRUE);
            //EXIT(TRUE);
            Myresult := CreateJsonPayload('1', 'True', DocNo);
            exit(Myresult);

        END ELSE BEGIN
            ItemJournalLine.RESET;
            ItemJournalLine.SETCURRENTKEY(ItemJournalLine."Production Barcode No");
            //M++
            /*{
            //ItemJournalLine.SETRANGE(ItemJournalLine."Journal Template Name",,ManuSetupRec."Production Template Name");
            //ItemJournalLine.SETRANGE(ItemJournalLine."Journal Batch Name",ManuSetupRec."Production Batch Name");
            ItemJournalLine.SETRANGE(ItemJournalLine."Journal Template Name", UserSetup."Journal Template Name");
                ItemJournalLine.SETRANGE(ItemJournalLine."Journal Batch Name", UserSetup."Journal Batch Name");

                ItemJournalLine.SETFILTER(ItemJournalLine."Production Barcode No", DocumentNo);
                IF ItemJournalLine.FINDLAST THEN BEGIN
                    DocNo := ItemJournalLine."Document No.";
                    EXIT(TRUE);
                END ELSE BEGIN
                    ItemJournalLine.RESET;

                    //ItemJournalLine.SETRANGE(ItemJournalLine."Journal Template Name",ManuSetupRec."Production Template Name");
                    //ItemJournalLine.SETRANGE(ItemJournalLine."Journal Batch Name",ManuSetupRec."Production Batch Name");
                    ItemJournalLine.SETRANGE(ItemJournalLine."Journal Template Name", UserSetup."Journal Template Name");
                    ItemJournalLine.SETRANGE(ItemJournalLine."Journal Batch Name", UserSetup."Journal Batch Name");
            }*/
            //MS--
            //MS++
            PH.RESET;
            PH.SetRange("Document Type", PH."Document Type"::Order);
            PH.SETFILTER("No.", DocumentNo);

            IF PH.FindFirst() THEN BEGIN
                ErrText1 := PH."Location Code";
                DocNo := DocumentNo;
                //MESSAGE('%1', PH."Location Code");
                ErrText := '';
                //EXIT(TRUE);
                Orderjson.Add('id', '1');
                Orderjson.Add('Success', 'True');
                Orderjson.Add('Message', '');
                Orderjson.Add('DocNo', DocNo);
                Orderjson.Add('ErrText', ErrText);
                Orderjson.Add('ErrText1', ErrText1);
                Orderjson.WriteTo(Myresult);
                Myresult := Myresult.Replace('\', '');
                exit(Myresult);


            END ELSE BEGIN
                ErrText := DocumentNo + 'Document Number Invalid';
                //EXIT(FALSE);
                Myresult := CreateJsonPayload('0', 'False', ErrText);
                exit(Myresult);
            END;
        END;
        //MS--
        //END;
    END;

    //*********************** RMPurchaseStockTake *********************
    PROCEDURE RMPurchaseStockTake(inputJson: Text[2024]): Text[1024]
    var
        //Function In
        SrlNo: Code[50];
        DocumentNo: Code[50];
        UID: Code[50];
        //Function Out
        ErrText: Text[550];
        flg: Boolean;

        PH: Record "Purchase Header";
        Text001: TextConst ENU = '%1 Invalid Document No.';
        PL: Record "Purchase Line";
        LN: Integer;
        DocType: Option Quote,Order,Invoice,"Credit Memo","Blanket Order","Return Order";
        Text002: TextConst ENU = '%1 Item no. not find';
        Text003: TextConst ENU = 'Quantity to Received can''t be greater then Quantity;ENN=Quantity to Received can''t be greater then Quantity';
        Qty1: Decimal;
        FlgModify: Boolean;
        MinusStr: Code[10];


        input: JsonObject;
        c: JsonToken;
        Myresult: Text[1024];
        Orderjson: JsonObject;


    BEGIN
        input.ReadFrom(inputJson);
        //Get ChilddBacode
        if input.Get('ChilddBacode', c) then begin
            SrlNo := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'ChilddBacode Node not found in Payload');
            exit(Myresult);
        end;

        //Get DocumentNo
        if input.Get('DocumentNo', c) then begin
            DocumentNo := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'DocumentNo Node not found in Payload');
            exit(Myresult);
        end;

        //Get UID
        if input.Get('UserId', c) then begin
            UID := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'UID Node not found in Payload');
            exit(Myresult);
        end;

        /*  SrlNo := '030323EC00054';
         DocumentNo := 'PO/2023-24/000009';
         UID := 'E101'; */


        FlgModify := FALSE;
        UserSetup.GET(UID);
        MinusStr := '';
        MinusStr := COPYSTR(SrlNo, 1, 1);
        IF MinusStr = '-' THEN
            SrlNo := DELSTR(SrlNo, 1, 1);
        BSNO.GET(SrlNo);

        IF NOT BSNO.GET(SrlNo) THEN BEGIN
            ErrText := SrlNo + ' Not found in Barcode Serial No. Table';
            //EXIT(FALSE);
            Myresult := CreateJsonPayload('0', 'False', ErrText);
            exit(Myresult);
        END ELSE BEGIN

            //Checking Tot Qty
            PurchLineRec.RESET;
            PurchLineRec.SETFILTER("Document No.", DocumentNo);
            PurchLineRec.SETRANGE("Document Type", PurchLineRec."Document Type"::Order);
            PurchLineRec.SETRANGE(Type, PurchLineRec.Type::Item);
            PurchLineRec.SETFILTER("No.", BSNO."Item Code");
            PurchLineRec.SETFILTER("Variant Code", BSNO."Variant Code");
            //FC 170922 PurchLineRec.SETFILTER("Location Code",BSNO."Current Location");
            PurchLineRec.SETFILTER(Quantity, '<>%1', 0);
            Qty1 := 0;
            IF PurchLineRec.FINDFIRST THEN
                REPEAT
                    //Qty1 += PurchLineRec.Quantity-PurchLineRec."Quantity Received"-PurchLineRec."Temp Qty To Receive"
                    Qty1 += PurchLineRec.Quantity - PurchLineRec."Quantity Received" - PurchLineRec."Qty. to Receive";
                UNTIL PurchLineRec.NEXT = 0;
            IF Qty1 = 0 THEN BEGIN
                ErrText := 'Qty exceed';
                //EXIT(FALSE);
                Myresult := CreateJsonPayload('0', 'False', ErrText);
                exit(Myresult);

            END;

            Qty1 := 0;
            PurchLineRec.RESET;
            PurchLineRec.SETFILTER("Document No.", DocumentNo);
            PurchLineRec.SETRANGE("Document Type", PurchLineRec."Document Type"::Order);
            PurchLineRec.SETRANGE(Type, PurchLineRec.Type::Item);
            PurchLineRec.SETFILTER("No.", BSNO."Item Code");
            //PurchLineRec.SETFILTER("Unit of Measure",BSNO."Unit of Measure Code");
            PurchLineRec.SETFILTER("Variant Code", BSNO."Variant Code");
            //FC 170922 PurchLineRec.SETFILTER("Location Code",BSNO."Current Location");
            PurchLineRec.SETFILTER(Quantity, '<>%1', 0);
            IF NOT PurchLineRec.FINDFIRST THEN BEGIN
                ErrText := PurchLineRec."No." + 'Item no. not find ';
                //EXIT(FALSE);
                Myresult := CreateJsonPayload('0', 'False', ErrText);
                exit(Myresult);

            END ELSE
                REPEAT
                    //Qty1 += PurchLineRec.Quantity-PurchLineRec."Quantity Received"-PurchLineRec."Temp Qty To Receive";
                    Qty1 := PurchLineRec.Quantity - PurchLineRec."Quantity Received" - PurchLineRec."Qty. to Receive";
                    IF Qty1 <> 0 THEN BEGIN
                        //FC 170922 PurchLineRec."Qty. to Receive"+=BSNO."Quantity (Base)" ;
                        PurchLineRec.VALIDATE("Temp Qty To Receive", PurchLineRec."Temp Qty To Receive" + BSNO."Quantity (Base)");

                        PurchLineRec.MODIFY(TRUE);

                        BSNO."Output Date" := TODAY;
                        BSNO."Purchase Order No." := PurchLineRec."Document No.";
                        BSNO."Purchase Line Order No." := PurchLineRec."Line No.";
                        BSNO.Tracking := BarCodeSrno.Tracking::Purchase;
                        BSNO.MODIFY(TRUE);
                        //MESSAGE('%1',PurchLineRec."Line No.");
                        //ErrText := 'Successfully';
                        FlgModify := TRUE;
                        //EXIT;
                    END;
                UNTIL PurchLineRec.NEXT = 0;
        END;

        IF FlgModify THEN BEGIN
            ErrText := 'Successfully';
            //EXIT(TRUE);
            Myresult := CreateJsonPayload('1', 'True', ErrText);
            exit(Myresult);
        END;
    END;

    procedure InsertrBarcode(inputJson: Text[2024]): Text[1024]
    var
        SCN: Record "Barcode Serial No.";
        Barcode: Code[50];
        input: JsonObject;
        c: JsonToken;
        Myresult: Text[1024];
        Orderjson: JsonObject;


    begin


        input.ReadFrom(inputJson);
        if input.Get('Barcode', c) then begin
            Barcode := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'Barcode Node not found in Payload');
            exit(Myresult);
        end;

        SCN.Init();
        SCN."Serial No." := Barcode;
        SCN.Insert(true);

        Myresult := CreateJsonPayload('1', 'True', '');
        exit(Myresult);
    end;

    //*********************** OnlineValidateTrnsfrShpBarcode *********************

    PROCEDURE OnlineValidateTrnsfrShpBarcode(inputJson: Text[2024]): Text[1024]
    VAR
        //Function In
        Barcode: Code[20];
        //Function Out
        ItemCode: Text[30];
        VariantCode: Text[30];
        UOM: Code[10];
        ItmCatalogCode: Text[30];
        QtyBase: Decimal;
        ErrText: Text[50];
        flag: Boolean;
        SalesPriceRec: Record "Sales Price";
        DOZVal: Decimal;
        input: JsonObject;
        c: JsonToken;
        Myresult: Text[1024];
        Orderjson: JsonObject;
    BEGIN

        input.ReadFrom(inputJson);
        //Get Barcode
        if input.Get('Barcode', c) then begin
            Barcode := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'Barcode Node not found in Payload');
            exit(Myresult);
        end;

        IF BSNO.GET(Barcode) THEN BEGIN
            IF (BSNO."Parent Serial No." = '') AND (BSNO."Blanket Order No." = '') THEN BEGIN
                IF (BSNO.Status <> 4) AND (BSNO.Status <> 5) AND (BSNO.Status <> 8) THEN BEGIN
                    ItemCode := BSNO."Item Code";
                    VariantCode := BSNO."Variant Code";
                    UOM := BSNO."Unit of Measure Code";
                    ItmCatalogCode := BSNO."Item Category Code";
                    QtyBase := BSNO."Quantity (Base)";
                    //EXIT(TRUE);
                    Orderjson.Add('id', '1');
                    Orderjson.Add('Success', 'True');
                    Orderjson.Add('Message', '');
                    Orderjson.Add('ItemCode', ItemCode);
                    Orderjson.Add('VariantCode', VariantCode);
                    Orderjson.Add('UOM', UOM);
                    Orderjson.Add('ItmCatalogCode', ItmCatalogCode);
                    Orderjson.Add('QtyBase', QtyBase);
                    Orderjson.WriteTo(Myresult);
                    Myresult := Myresult.Replace('\', '');
                    exit(Myresult);
                END;
            END ELSE BEGIN
                ErrText := 'This Item of Serial No=' + Barcode + ' either have Parent Serial No. or Transfer Order No. or Transfer Order Line No. or Blanket Order No.or Blanket Order Line No. or Status';
                //EXIT(FALSE);
                Myresult := CreateJsonPayload('0', 'False', ErrText);
                exit(Myresult);
            END;

            IF BSNO.MRP <> 0 THEN BEGIN
                SalesPriceRec.RESET;
                SalesPriceRec.SETFILTER("Sales Code", '%1', 'WSP_2018');
                SalesPriceRec.SETRANGE("Item No.", BSNO."Item Code");
                SalesPriceRec.SETRANGE("Variant Code", BSNO."Variant Code");
                IF SalesPriceRec.FINDFIRST THEN BEGIN
                    IF SalesPriceRec."Unit of Measure Code" = 'DOZ' THEN
                        DOZVal := SalesPriceRec."MRP Price" / 12
                    ELSE
                        DOZVal := SalesPriceRec."MRP Price";
                END;
                IF DOZVal <> BSNO.MRP THEN BEGIN
                    ErrText := 'MRP Price Not Match';
                    Myresult := CreateJsonPayload('0', 'False', ErrText);
                    exit(Myresult);
                END;
            END;
        END ELSE BEGIN
            ErrText := 'Barcode Does not Exists in Barcode Serial List';
            //EXIT(FALSE);
            Myresult := CreateJsonPayload('0', 'False', ErrText);
            exit(Myresult);
        END;
    END;


    //*********************** OnlineTransferShipmentLooseToFresh *********************

    PROCEDURE OnlineTransferShipmentLooseToFresh(inputJson: Text[2024]): Text[1024]
    var
        //Function In
        Barcode: Code[20];
        TransferOrder: Code[20];
        FromLocation: Code[10];

        //Function Out
        ErrText: Text[250];
        flg: Boolean;

        TransferLine: Record "Transfer Line";
        TransferOrderLineNo: Integer;
        ItemRec: Record "Item";
        input: JsonObject;
        c: JsonToken;
        Myresult: Text[1024];
        Orderjson: JsonObject;
    BEGIN

        input.ReadFrom(inputJson);
        //Get Barcode
        if input.Get('Barcode', c) then begin
            Barcode := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'Barcode Node not found in Payload');
            exit(Myresult);
        end;

        //Get TransferOrder
        if input.Get('TransferOrder', c) then begin
            TransferOrder := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'TransferOrder Node not found in Payload');
            exit(Myresult);
        end;

        //Get FromLocation
        if input.Get('FromLocation', c) then begin
            FromLocation := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'FromLocation Node not found in Payload');
            exit(Myresult);
        end;


        TransferLine.RESET;
        TransferLine.SETFILTER("Document No.", TransferOrder);
        IF TransferLine.FINDLAST THEN
            TransferOrderLineNo := TransferLine."Line No." + 10000
        ELSE
            TransferOrderLineNo := 10000;

        IF BSNO.GET(Barcode) THEN BEGIN
            IF BSNO."Transfer Order No." = '' THEN BEGIN
                //Barcode Serial No.
                BSNO.Status := BSNO.Status::"Received in Store";
                BSNO.VALIDATE("Transfer Order No.", TransferOrder);
                BSNO.VALIDATE("Transfer Order Line No.", TransferOrderLineNo);
                BSNO."Current Location" := 'STORE';
                BSNO.Tracking := BSNO.Tracking::Transfer;
                BSNO.MODIFY(TRUE);
                //Transfer Line
                IF TransferLine.GET(TransferOrder, TransferOrderLineNo) THEN BEGIN
                    ErrText := 'This Item Already Exists in this Tranfer Order No';
                    //EXIT(FALSE);
                    Myresult := CreateJsonPayload('0', 'False', ErrText);
                    exit(Myresult);
                END ELSE BEGIN
                    TransferLine.INIT;
                    TransferLine."Document No." := TransferOrder;
                    TransferLine."Line No." := TransferOrderLineNo;
                    TransferLine."Transfer-from Code" := FromLocation;
                    TransferLine.INSERT(TRUE);
                    TransferLine.VALIDATE("Item No.", BSNO."Item Code");
                    TransferLine.VALIDATE("Variant Code", BSNO."Variant Code");

                    IF ItemRec.GET(BSNO."Item Code") THEN;
                    TransferLine.VALIDATE("Unit of Measure Code", ItemRec."Sales Unit of Measure");

                    IF (ItemRec."Sales Unit of Measure" = 'DOZ') AND (BSNO."Base Unit of Measure" = 'DOZ') THEN BEGIN
                        TransferLine.VALIDATE(Quantity, BSNO."Quantity (Base)");
                        TransferLine.VALIDATE("Qty. to Ship", BSNO."Quantity (Base)");
                    END ELSE
                        IF (ItemRec."Sales Unit of Measure" = 'PCS') AND (BSNO."Base Unit of Measure" = 'PCS') THEN BEGIN
                            TransferLine.VALIDATE(Quantity, BSNO."Quantity (Base)");
                            TransferLine.VALIDATE("Qty. to Ship", BSNO."Quantity (Base)");
                        END ELSE
                            IF (ItemRec."Sales Unit of Measure" = 'DOZ') AND (BSNO."Base Unit of Measure" = 'PCS') THEN BEGIN
                                TransferLine.VALIDATE(Quantity, BSNO."Quantity (Base)" / 12);
                                TransferLine.VALIDATE("Qty. to Ship", BSNO."Quantity (Base)" / 12);
                            END;
                    TransferLine.VALIDATE("Scanned Barcode", BSNO."Serial No.");
                    TransferLine.VALIDATE("Transfer Price", BSNO.MRP);
                    TransferLine.MODIFY(TRUE);
                END;
                //EXIT(TRUE);
                Orderjson.Add('id', '1');
                Orderjson.Add('Success', 'True');
                Orderjson.Add('Message', '');
                Orderjson.WriteTo(Myresult);
                exit(Myresult);
            END ELSE BEGIN
                ErrText := 'Barcode Already Attached with the ' + BSNO."Transfer Order No." + ' Transfer Order Number';
                //EXIT(FALSE);
                Myresult := CreateJsonPayload('0', 'False', ErrText);
                exit(Myresult);
            END;
        END ELSE BEGIN
            ErrText := 'Barcode Does not Exists in Barcode Serial No Table';
            //EXIT(FALSE);
            Myresult := CreateJsonPayload('0', 'False', ErrText);
            exit(Myresult);
        END;
    END;

    //*********************** TransferShipment *********************
    PROCEDURE TransferShipment(inputJson: Text[2024]): Text[1024]
    var
        //Function In
        Barcode: Code[20];
        TransferOrder: Code[20];
        ToLocation: Code[10];
        FromLocation: Code[10];
        WorkOderNo: Code[20];
        LotNo: Code[10];
        TrnsferFrmBnCde: Code[10];
        TrnsferToBnCde: Code[10];

        //Function Out
        ErrText: Text[1024];
        flag: Boolean;
        TransferLine: Record "Transfer Line";
        TransferOrderLineNo: Integer;
        input: JsonObject;
        c: JsonToken;
        Myresult: Text[1024];
        Orderjson: JsonObject;

    BEGIN

        input.ReadFrom(inputJson);
        //1-Get Barcode
        if input.Get('Barcode', c) then begin
            Barcode := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'Barcode Node not found in Payload');
            exit(Myresult);
        end;
        //2-Get TransferOrder
        if input.Get('TransferOrder', c) then begin
            TransferOrder := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'TransferOrder Node not found in Payload');
            exit(Myresult);
        end;
        //3-Get ToLocation
        if input.Get('ToLocation', c) then begin
            ToLocation := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'ToLocation Node not found in Payload');
            exit(Myresult);
        end;

        //4-Get FromLocation
        if input.Get('FromLocation', c) then begin
            FromLocation := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'FromLocation Node not found in Payload');
            exit(Myresult);
        end;
        //5-Get WorkOderNo
        if input.Get('WorkOderNo', c) then begin
            WorkOderNo := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'WorkOderNo Node not found in Payload');
            exit(Myresult);
        end;
        //6-Get LotNo
        if input.Get('LotNo', c) then begin
            LotNo := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'LotNo Node not found in Payload');
            exit(Myresult);
        end;
        //7-Get TrnsferFrmBnCde
        if input.Get('TrnsferFrmBnCde', c) then begin
            TrnsferFrmBnCde := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'TrnsferFrmBnCde Node not found in Payload');
            exit(Myresult);
        end;

        //8-Get TrnsferToBnCde
        if input.Get('TrnsferToBnCde', c) then begin
            TrnsferToBnCde := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'TrnsferToBnCde Node not found in Payload');
            exit(Myresult);
        end;

        TransferLine.RESET;
        TransferLine.SETFILTER("Document No.", TransferOrder);
        IF TransferLine.FINDLAST THEN
            TransferOrderLineNo := TransferLine."Line No." + 10000
        ELSE
            TransferOrderLineNo := 10000;

        IF BSNO.GET(Barcode) THEN BEGIN
            IF BSNO."Transfer Order No." = '' THEN BEGIN
                //Barcode Serial No.
                BSNO.Status := BSNO.Status::"In-Transit";
                BSNO.VALIDATE("Transfer Order No.", TransferOrder);
                BSNO.VALIDATE("Transfer Order Line No.", TransferOrderLineNo);
                BSNO.VALIDATE("Phy. Lot No.", LotNo);
                BSNO.MODIFY(TRUE);

                //Transfer Line
                IF TransferLine.GET(TransferOrder, TransferOrderLineNo) THEN BEGIN
                    ErrText := 'This Item Already Exists in this Tranfer Order No';
                    //EXIT(FALSE);
                    Myresult := CreateJsonPayload('0', 'False', ErrText);
                    exit(Myresult);
                END ELSE BEGIN
                    TransferLine.INIT;
                    TransferLine.VALIDATE("Document No.", TransferOrder);
                    TransferLine.VALIDATE("Line No.", TransferOrderLineNo);
                    TransferLine.VALIDATE(TransferLine."Transfer-from Code", FromLocation);
                    TransferLine.VALIDATE(TransferLine."Transfer-to Code", ToLocation);
                    TransferLine.INSERT(TRUE);
                    TransferLine.VALIDATE("Item No.", BSNO."Item Code");
                    TransferLine.VALIDATE("Variant Code", BSNO."Variant Code");
                    TransferLine.VALIDATE(Quantity, BSNO."Quantity (Base)");
                    TransferLine.VALIDATE("Unit of Measure Code", BSNO."Base Unit of Measure");
                    TransferLine.VALIDATE("Qty. to Ship", BSNO."Quantity (Base)");
                    TransferLine.VALIDATE("Production Order No.", LotNo);
                    TransferLine.VALIDATE("Scanned Barcode", BSNO."Serial No.");
                    //TransferLine.VALIDATE("Transfer-To Bin Code", 'CONSUMPTION');
                    TransferLine.VALIDATE("Transfer-from Bin Code", TrnsferFrmBnCde);
                    TransferLine.VALIDATE("Transfer-To Bin Code", TrnsferToBnCde);
                    TransferLine.MODIFY(TRUE);
                END;
                //EXIT(TRUE);
                Myresult := CreateJsonPayload('1', 'True', ErrText);
                exit(Myresult);

            END ELSE BEGIN
                ErrText := 'Barcode Already Attached with the ' + BSNO."Transfer Order No." + ' Transfer Order Number';
                //EXIT(FALSE);
                Myresult := CreateJsonPayload('0', 'False', ErrText);
                exit(Myresult);
            END;
        END ELSE BEGIN
            ErrText := 'Barcode Does not Exists in Barcode Serial No Table';
            //EXIT(FALSE);
            Myresult := CreateJsonPayload('0', 'False', ErrText);
            exit(Myresult);
        END;
    END;

    //*********************** OnlineValidateLocation *********************
    PROCEDURE OnlineValidateLocation(inputJson: Text[2024]): Text[1024]
    var
        //Function In
        Location: Code[30];
        //Function Out
        ErrText: Text[1024];
        Flag: Boolean;
        LocationRec: Record Location;
        input: JsonObject;
        c: JsonToken;
        Myresult: Text[1024];
        Orderjson: JsonObject;
    BEGIN

        input.ReadFrom(inputJson);
        //Get Srlno
        if input.Get('Location', c) then begin
            Location := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'Location Node not found in Payload');
            exit(Myresult);
        end;

        IF LocationRec.GET(Location) THEN BEGIN
            ErrText := LocationRec.Name;
            //EXIT(TRUE);
            Myresult := CreateJsonPayload('1', 'True', ErrText);
            exit(Myresult);
        END ELSE BEGIN
            ErrText := 'This Location Does Not exists in Location Setup';
            //EXIT(FALSE);
            Myresult := CreateJsonPayload('0', 'False', ErrText);
            exit(Myresult);
        END;
    END;


    //*********************** OnlineCreateTransferOrderNo *********************

    PROCEDURE OnlineCreateTransferOrderNo(VAR OrderNo: Code[20]);
    BEGIN
        RANDOMIZE();
        OrderNo := NoSeriesMgt.GetNextNo('TO-ECOM', TODAY, TRUE);
    END;


    //*********************** CreateTransferHeader *********************

    PROCEDURE CreateTransferHeader(inputJson: Text[2024]): Text[1024]
    var
        //Function In
        TransferOrder: Code[30];
        FromLocation: Code[30];
        ToLocation: Code[30];
        WorkOderNo: Code[30];
        UserID: Code[30];
        //Function Out
        ErrText: Text[150];
        flag: Boolean;
        TransferHeader: Record "Transfer Header";
        BinContentRec: Record "Transfer Header";

        input: JsonObject;
        c: JsonToken;
        Myresult: Text[1024];
        Orderjson: JsonObject;

    BEGIN


        input.ReadFrom(inputJson);
        //Get TransferOrder
        if input.Get('TransferOrder', c) then begin
            TransferOrder := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'TransferOrder Node not found in Payload');
            exit(Myresult);
        end;
        //Get FromLocation
        if input.Get('FromLocation', c) then begin
            FromLocation := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'FromLocation Node not found in Payload');
            exit(Myresult);
        end;
        //Get ToLocation
        if input.Get('ToLocation', c) then begin
            ToLocation := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'ToLocation Node not found in Payload');
            exit(Myresult);
        end;
        /* //Get WorkOderNo
        if input.Get('WorkOderNo', c) then begin
            WorkOderNo := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'WorkOderNo Node not found in Payload');
            exit(Myresult);
        end; */
        //Get UserID
        if input.Get('UserID', c) then begin
            UserID := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'UserID Node not found in Payload');
            exit(Myresult);
        end;


        TransferHeader.INIT;
        TransferHeader.VALIDATE("No.", TransferOrder);
        TransferHeader.INSERT(TRUE);
        TransferHeader.VALIDATE("Transfer-from Code", FromLocation);
        TransferHeader.VALIDATE("Transfer-to Code", ToLocation);
        TransferHeader.VALIDATE("In-Transit Code", 'IN-TRANSIT');
        TransferHeader.VALIDATE("Posting Date", TODAY);
        TransferHeader.VALIDATE("Shipment Date", TODAY);
        TransferHeader."Work Order No." := WorkOderNo;
        TransferHeader."Assigned User ID" := UserID;
        if (TransferHeader.MODIFY(TRUE)) then begin
            COMMIT;
            //EXIT(TRUE);
            //END;
            Orderjson.Add('id', '1');
            Orderjson.Add('Success', 'True');
            Orderjson.Add('Message', 'Transfer Order ' + TransferHeader."No." + ' Create Sucessfully ');
            Orderjson.WriteTo(Myresult);
            Myresult := Myresult.Replace('\', '');
            exit(Myresult);
        end else begin
            Orderjson.Add('id', '0');
            Orderjson.Add('Success', 'False');
            Orderjson.Add('Message', 'Transfer Order Not Created ');
            Orderjson.WriteTo(Myresult);
            Myresult := Myresult.Replace('\', '');
            exit(Myresult);
        end;

    END;


    //*********************** OnlineTransferShipment *********************
    PROCEDURE OnlineTransferShipment(inputJson: Text[2024]): Text[1024]
    var
        //Function In
        Barcode: Code[20];
        TransferOrder: Code[20];
        ToLocation: Code[20];
        FromLocation: Code[10];
        //Function Out
        ErrText: Text[250];
        flag: Boolean;
        TransferLine: Record "Transfer Line";
        TransferOrderLineNo: Integer;
        ItemRec: Record "Item";

        input: JsonObject;
        c: JsonToken;
        Myresult: Text[1024];
        Orderjson: JsonObject;


    BEGIN

        input.ReadFrom(inputJson);
        //Get Barcode
        if input.Get('Barcode', c) then begin
            Barcode := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'Barcode Node not found in Payload');
            exit(Myresult);
        end;
        //Get TransferOrder
        if input.Get('TransferOrder', c) then begin
            TransferOrder := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'TransferOrder Node not found in Payload');
            exit(Myresult);
        end;
        //Get ToLocation
        if input.Get('ToLocation', c) then begin
            ToLocation := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'ToLocation Node not found in Payload');
            exit(Myresult);
        end;
        //Get FromLocation
        if input.Get('FromLocation', c) then begin
            FromLocation := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'FromLocation Node not found in Payload');
            exit(Myresult);
        end;
        //Get FromLocation
        if input.Get('FromLocation', c) then begin
            FromLocation := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'FromLocation Node not found in Payload');
            exit(Myresult);
        end;


        TransferLine.RESET;
        TransferLine.SETFILTER("Document No.", TransferOrder);
        IF TransferLine.FINDLAST THEN
            TransferOrderLineNo := TransferLine."Line No." + 10000
        ELSE
            TransferOrderLineNo := 10000;



        IF BSNO.GET(Barcode) THEN BEGIN
            IF BSNO.Status <> BSNO.Status::"Ship to ECOM" THEN BEGIN
                BSNO.Status := BSNO.Status::"Ship to ECOM";
                BSNO.VALIDATE("Transfer Order No.", TransferOrder);
                BSNO.VALIDATE("Transfer Order Line No.", TransferOrderLineNo);
                BSNO."Current Location" := 'E-COM';
                BSNO.Tracking := BSNO.Tracking::Transfer;
                BSNO.MODIFY(TRUE);
                IF TransferLine.GET(TransferOrder, TransferOrderLineNo) THEN BEGIN
                    ErrText := 'This Item Already Exists in this Tranfer Order No';
                    //EXIT(FALSE);
                    Orderjson.Add('id', '0');
                    Orderjson.Add('Success', 'False');
                    Orderjson.Add('Message', ErrText);
                    Orderjson.WriteTo(Myresult);
                    exit(Myresult);
                END ELSE BEGIN
                    TransferLine.INIT;
                    TransferLine.VALIDATE("Document No.", TransferOrder);
                    TransferLine.VALIDATE("Line No.", TransferOrderLineNo);

                    TransferLine."Transfer-from Code" := FromLocation;
                    TransferLine."Transfer-to Code" := ToLocation;

                    TransferLine.INSERT(TRUE);

                    TransferLine.VALIDATE("Item No.", BSNO."Item Code");
                    TransferLine.VALIDATE("Variant Code", BSNO."Variant Code");
                    TransferLine.VALIDATE("MRP Price", BSNO.MRP);

                    IF ItemRec.GET(BSNO."Item Code") THEN;
                    TransferLine.VALIDATE("Unit of Measure Code", ItemRec."Sales Unit of Measure");

                    IF (ItemRec."Sales Unit of Measure" = 'DOZ') AND (BSNO."Base Unit of Measure" = 'DOZ') THEN BEGIN
                        TransferLine.VALIDATE(Quantity, BSNO."Quantity (Base)");
                        TransferLine.VALIDATE("Qty. to Ship", BSNO."Quantity (Base)");
                    END ELSE
                        IF (ItemRec."Sales Unit of Measure" = 'PCS') AND (BSNO."Base Unit of Measure" = 'PCS') THEN BEGIN
                            TransferLine.VALIDATE(Quantity, BSNO."Quantity (Base)");
                            TransferLine.VALIDATE("Qty. to Ship", BSNO."Quantity (Base)");
                        END ELSE
                            IF (ItemRec."Sales Unit of Measure" = 'DOZ') AND (BSNO."Base Unit of Measure" = 'PCS') THEN BEGIN
                                TransferLine.VALIDATE(Quantity, BSNO."Quantity (Base)" / 12);
                                TransferLine.VALIDATE("Qty. to Ship", BSNO."Quantity (Base)" / 12);
                            END;


                    TransferLine.VALIDATE("Scanned Barcode", BSNO."Serial No.");
                    IF TransferLine."Unit of Measure" = 'DOZ' THEN
                        TransferLine.VALIDATE("Transfer Price", ItemRec."Default Tranfer Price" * 12);
                    IF TransferLine."Unit of Measure" = 'PCS' THEN
                        TransferLine.VALIDATE("Transfer Price", ItemRec."Default Tranfer Price");
                    TransferLine.MODIFY(TRUE);
                END;
                //EXIT(TRUE);
                Orderjson.Add('id', '1');
                Orderjson.Add('Success', 'True');
                Orderjson.Add('Message', '');
                Orderjson.WriteTo(Myresult);
                exit(Myresult);
            END ELSE BEGIN
                ErrText := 'Barcode Already Attached with the ' + BSNO."Transfer Order No." + ' Transfer Order Number';
                //EXIT(FALSE);
                Orderjson.Add('id', '0');
                Orderjson.Add('Success', 'False');
                Orderjson.Add('Message', ErrText);
                Orderjson.WriteTo(Myresult);
                exit(Myresult);
            END;

        END ELSE BEGIN
            ErrText := 'Barcode Does not Exists in Barcode Serial No Table';
            //EXIT(FALSE);
            Orderjson.Add('id', '0');
            Orderjson.Add('Success', 'False');
            Orderjson.Add('Message', ErrText);
            Orderjson.WriteTo(Myresult);
            exit(Myresult);
        END;
    END;


    //*********************** ValidateDocumentNo *********************
    PROCEDURE ValidateDocumentNo(inputJson: Text[2024]): Text[1024]
    var
        //Function In
        DocumentNo: Code[30];
        UID: Text[50];
        //Function Out
        DocNo: Code[30];
        ErrText: Text[250];
        flag: Boolean;

        input: JsonObject;
        c: JsonToken;
        Myresult: Text[1024];
        Orderjson: JsonObject;


    BEGIN

        input.ReadFrom(inputJson);
        //Get DocumentNo
        if input.Get('DocumentNo', c) then begin
            DocumentNo := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'DocumentNo Node not found in Payload');
            exit(Myresult);
        end;
        //Get UID
        if input.Get('UID', c) then begin
            UID := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'UID Node not found in Payload');
            exit(Myresult);
        end;


        IF NOT UserSetup.GET(UID) THEN BEGIN
            ErrText := UID + ' User ID not Found in User Setup Table ';
            //EXIT(FALSE);
            Myresult := CreateJsonPayload('0', 'False', ErrText);
            exit(Myresult);
        END;


        IF (DocumentNo = 'NEW') THEN BEGIN
            DocNo := NoSeriesMgt.GetNextNo('IJO', TODAY, TRUE);
            //EXIT(TRUE);
            Myresult := CreateJsonPayload('1', 'True', DocNo);
            exit(Myresult);

        END ELSE BEGIN
            ItemJournalLine.RESET;
            ItemJournalLine.SETCURRENTKEY(ItemJournalLine."Production Barcode No");
            ItemJournalLine.SETRANGE(ItemJournalLine."Journal Template Name", 'ITEM');

            ItemJournalLine.SETRANGE(ItemJournalLine."Journal Batch Name", UserSetup.StockTakingBatch);

            ItemJournalLine.SETFILTER(ItemJournalLine."Production Barcode No", DocumentNo);
            IF ItemJournalLine.FINDLAST THEN BEGIN
                DocNo := ItemJournalLine."Document No.";
                //EXIT(TRUE);
                Myresult := CreateJsonPayload('1', 'True', DocNo);
                exit(Myresult);
            END ELSE BEGIN
                ItemJournalLine.RESET;
                ItemJournalLine.SETCURRENTKEY(ItemJournalLine."Document No.");
                ItemJournalLine.SETRANGE(ItemJournalLine."Journal Template Name", 'ITEM');

                ItemJournalLine.SETRANGE(ItemJournalLine."Journal Batch Name", UserSetup."Journal Batch Name");


                ItemJournalLine.SETFILTER(ItemJournalLine."Document No.", DocumentNo);
                IF ItemJournalLine.FINDFIRST THEN BEGIN
                    DocNo := DocumentNo;
                    ErrText := '';
                    //EXIT(TRUE);
                    Myresult := CreateJsonPayload('1', 'True', DocNo);
                    exit(Myresult);

                END ELSE BEGIN
                    ErrText := DocumentNo + ' Document Number Invalid';
                    //EXIT(FALSE);
                    Myresult := CreateJsonPayload('1', 'False', ErrText);
                    exit(Myresult);
                END;
            END;
        END;
    END;

    //*********************** ValidateArticalBarcode *********************
    PROCEDURE ValidateArticalBarcode(inputJson: Text[2024]): Text[1024]
    VAR
        //Function In
        Srlno: Code[50];
        DocNo: Code[50];

        //Function Out
        ItemCode: Text[50];
        VariantCode: Text[50];
        Description: Text[50];
        UOM: Code[10];
        Qty: Decimal;
        QTYBase: Decimal;
        ErrText: Text[100];
        flg: Boolean;


        ItemRec: Record "Item";
        MinusStr: Code[10];
        ItemVariantRec: Record "Item Variant";
        ItemVariantFRec: Record "Item Variant";

        input: JsonObject;
        c: JsonToken;
        Myresult: Text[1024];
        Orderjson: JsonObject;


    BEGIN


        input.ReadFrom(inputJson);
        //Get Srlno
        if input.Get('Srlno', c) then begin
            Srlno := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'Srlno Node not found in Payload');
            exit(Myresult);
        end;

        //Get DocNo
        if input.Get('DocNo', c) then begin
            DocNo := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'DocNo Node not found in Payload');
            exit(Myresult);
        end;

        BSNO.RESET;
        MinusStr := '';
        MinusStr := COPYSTR(Srlno, 1, 1);
        IF MinusStr = '-' THEN
            Srlno := DELSTR(Srlno, 1, 1);

        IF NOT (MinusStr = '-') THEN BEGIN
            ItemVariantRec.RESET;
            ItemVariantRec.SETRANGE("Artical Barcode", Srlno);
            //ItemVariantFRec.SETRANGE("Piece Barcode",Srlno);
            IF NOT ItemVariantRec.FINDFIRST THEN BEGIN
                ItemVariantFRec.RESET;
                //
                IF NOT ItemVariantFRec.FINDFIRST THEN BEGIN
                    ErrText := Srlno + ' Atrical Barcode/Piece Barcode not found in Item Variant Table';
                    //EXIT(FALSE);
                    Myresult := CreateJsonPayload('0', 'False', ErrText);
                    exit(Myresult);
                END ELSE BEGIN
                    ItemCode := ItemVariantFRec."Item No.";
                    VariantCode := ItemVariantFRec.Code;
                    IF ItemRec.GET(ItemCode) THEN BEGIN
                        Description := ItemRec.Description;
                        UOM := ItemRec."Base Unit of Measure";
                        Qty := 1;
                        QTYBase := 1;
                    END;
                    ErrText := '';
                    //EXIT(TRUE);
                    Orderjson.Add('id', '1');
                    Orderjson.Add('Success', 'true');
                    Orderjson.Add('Message', ErrText);
                    Orderjson.Add('ItemCode', ItemCode);
                    Orderjson.Add('VariantCode', VariantCode);
                    Orderjson.Add('Description', Description);
                    Orderjson.Add('UOM', UOM);
                    Orderjson.Add('Qty', Qty);
                    Orderjson.Add('QTYBase', QTYBase);
                    Orderjson.WriteTo(Myresult);
                    exit(Myresult);
                END;
            END ELSE BEGIN
                ItemCode := ItemVariantRec."Item No.";
                VariantCode := ItemVariantRec.Code;
                IF ItemRec.GET(ItemCode) THEN BEGIN
                    Description := ItemRec.Description;
                    UOM := ItemRec."Base Unit of Measure";
                    Qty := 1;
                    QTYBase := 1;
                END;
                ErrText := '';
                //EXIT(TRUE);
                Orderjson.Add('id', '1');
                Orderjson.Add('Success', 'true');
                Orderjson.Add('Message', ErrText);
                Orderjson.Add('ItemCode', ItemCode);
                Orderjson.Add('VariantCode', VariantCode);
                Orderjson.Add('Description', Description);
                Orderjson.Add('UOM', UOM);
                Orderjson.Add('Qty', Qty);
                Orderjson.Add('QTYBase', QTYBase);
                exit(Myresult);
            END;
        END ELSE BEGIN
            ItemVariantRec.RESET;
            ItemVariantRec.SETRANGE("Artical Barcode", Srlno);
            //ItemVariantFRec.SETRANGE("Piece Barcode",Srlno);
            IF NOT ItemVariantRec.FINDFIRST THEN BEGIN
                ItemVariantFRec.RESET;
                //ItemVariantFRec.SETRANGE("Piece Barcode",Srlno);
                IF NOT ItemVariantFRec.FINDFIRST THEN BEGIN
                    ErrText := Srlno + ' Atrical Barcode/Piece Barcode not found in Item Variant Table';
                    //EXIT(FALSE);
                    Myresult := CreateJsonPayload('1', 'True', ErrText);
                    exit(Myresult);
                END ELSE BEGIN
                    ItemCode := ItemVariantFRec."Item No.";
                    VariantCode := ItemVariantFRec.Code;
                    IF ItemRec.GET(ItemCode) THEN BEGIN
                        Description := ItemRec.Description;
                        UOM := ItemRec."Base Unit of Measure";
                        Qty := 1;
                        QTYBase := 1;
                    END;
                    ErrText := '';
                    //EXIT(TRUE);
                    Orderjson.Add('id', '1');
                    Orderjson.Add('Success', 'true');
                    Orderjson.Add('Message', ErrText);
                    Orderjson.Add('ItemCode', ItemCode);
                    Orderjson.Add('VariantCode', VariantCode);
                    Orderjson.Add('Description', Description);
                    Orderjson.Add('UOM', UOM);
                    Orderjson.Add('Qty', Qty);
                    Orderjson.Add('QTYBase', QTYBase);
                    exit(Myresult);
                END;
            END ELSE BEGIN
                ItemCode := ItemVariantRec."Item No.";
                VariantCode := ItemVariantRec.Code;
                IF ItemRec.GET(ItemCode) THEN BEGIN
                    Description := ItemRec.Description;
                    UOM := ItemRec."Base Unit of Measure";
                    Qty := 1;
                    QTYBase := 1;
                END;
                ErrText := '';
                //EXIT(TRUE);
                Orderjson.Add('id', '1');
                Orderjson.Add('Success', 'true');
                Orderjson.Add('Message', ErrText);
                Orderjson.Add('ItemCode', ItemCode);
                Orderjson.Add('VariantCode', VariantCode);
                Orderjson.Add('Description', Description);
                Orderjson.Add('UOM', UOM);
                Orderjson.Add('Qty', Qty);
                Orderjson.Add('QTYBase', QTYBase);
                exit(Myresult);
            END;
        END;
    END;

    //*********************** PCSStockTake *********************
    PROCEDURE PCSStockTake(inputJson: Text[2024]): Text[1024]
    VAR
        //Function In
        SrlNo: Code[50];
        DocumentNo: Code[50];
        UID: Code[50];

        //Function Out
        ErrText: Text[50];
        flg: Boolean;


        Qty1: Decimal;
        MinusStr: Code[10];
        ItemVariantRec: Record "Item Variant";
        ItemVariantFRec: Record "Item Variant";
        ItemCode: Code[20];
        VariantCode: Code[20];
        Description: Text[100];
        UOM: Code[20];
        Qty: Decimal;
        QTYBase: Decimal;
        IJLFindTemp: Record 50055;


        input: JsonObject;
        c: JsonToken;
        Myresult: Text[1024];
        Orderjson: JsonObject;



    BEGIN


        input.ReadFrom(inputJson);
        //Get Srlno
        if input.Get('Srlno', c) then begin
            Srlno := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'Srlno Node not found in Payload');
            exit(Myresult);
        end;

        //Get DocumentNo
        if input.Get('DocumentNo', c) then begin
            DocumentNo := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'DocumentNo Node not found in Payload');
            exit(Myresult);
        end;

        //Get UID
        if input.Get('UID', c) then begin
            UID := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'UID Node not found in Payload');
            exit(Myresult);
        end;



        UserSetup.GET(UID);
        CompInfoRec.GET();

        MinusStr := '';
        MinusStr := COPYSTR(SrlNo, 1, 1);
        IF MinusStr = '-' THEN
            SrlNo := DELSTR(SrlNo, 1, 1);

        ItemVariantRec.RESET;
        ItemVariantRec.SETRANGE("Artical Barcode", SrlNo);
        IF NOT ItemVariantRec.FINDFIRST THEN BEGIN
            ItemVariantFRec.RESET;
            IF NOT ItemVariantFRec.FINDFIRST THEN BEGIN
                ErrText := SrlNo + ' Atrical Barcode/Piece Barcode not found in Item Variant Table';
                //EXIT(FALSE);
                Myresult := CreateJsonPayload('0', 'False', ErrText);
                exit(Myresult);
            END ELSE BEGIN
                ItemCode := ItemVariantFRec."Item No.";
                VariantCode := ItemVariantFRec.Code;
                IF ItemRec.GET(ItemCode) THEN BEGIN
                    Description := ItemRec.Description;
                    UOM := ItemRec."Base Unit of Measure";
                    Qty := 1;
                    QTYBase := 1;
                END;
            END;
        END ELSE BEGIN
            ItemCode := ItemVariantRec."Item No.";
            VariantCode := ItemVariantRec.Code;
            IF ItemRec.GET(ItemCode) THEN BEGIN
                Description := ItemRec.Description;
                UOM := ItemRec."Base Unit of Measure";
                Qty := 1;
                QTYBase := 1;
            END;
        END;

        IF NOT (MinusStr = '-') THEN BEGIN
            RANDOMIZE();
            LastEntryNo := RANDOM(2147483647) + ActiveSession."Session ID";

            IJLFindTemp.RESET;
            IJLFindTemp.SETRANGE("Journal Template Name", 'ITEM');
            IJLFindTemp.SETRANGE("Journal Batch Name", UserSetup.StockTakingBatch);
            IJLFindTemp.SETRANGE("Document No.", DocumentNo);
            IJLFindTemp.SETRANGE("Item No.", ItemCode);
            IJLFindTemp.SETRANGE("Variant Code", VariantCode);
            IF NOT IJLFindTemp.FINDFIRST THEN BEGIN
                ItemJournalLineTemp.INIT;
                ItemJournalLineTemp.VALIDATE("Posting Date", TODAY);
                ItemJournalLineTemp.VALIDATE("Line No.", LastEntryNo + 1);
                ItemJournalLineTemp.VALIDATE("Item No.", ItemCode);
                ItemJournalLineTemp.VALIDATE("Variant Code", VariantCode);
                ItemJournalLineTemp.VALIDATE(Quantity, 1);
                ItemJournalLineTemp.VALIDATE("Location Code", UserSetup."User Location");
                ItemJournalLineTemp.VALIDATE("Entry Type", ItemJournalLineTemp."Entry Type"::"Positive Adjmt.");
                ItemJournalLineTemp.VALIDATE("Reason Code", 'STOCKTAKE');
                ItemJournalLineTemp.VALIDATE("Production Barcode No", SrlNo);
                ItemJournalLineTemp.VALIDATE("Unit of Measure Code", UOM);
                ItemJournalLineTemp.VALIDATE("Phy. Lot No.", '');
                ItemJournalLineTemp.VALIDATE("Journal Template Name", 'ITEM');
                ItemJournalLineTemp.VALIDATE("Journal Batch Name", UserSetup.StockTakingBatch);
                ItemJournalLineTemp.VALIDATE("Document No.", DocumentNo);
                ItemJournalLineTemp.INSERT(TRUE);
            END ELSE BEGIN
                IJLFindTemp.VALIDATE(Quantity, IJLFindTemp.Quantity + 1);
                IJLFindTemp.MODIFY(TRUE);
            END;

            IF GETLASTERRORTEXT <> '' THEN BEGIN
                ErrText := GETLASTERRORTEXT;
                //EXIT(FALSE);
                Myresult := CreateJsonPayload('0', 'False', ErrText);
                exit(Myresult);

            END ELSE BEGIN
                ErrText := '';
                //EXIT(TRUE);
                Myresult := CreateJsonPayload('1', 'True', ErrText);
                exit(Myresult);
            END;
        END ELSE BEGIN
            ErrText := '- not accept';
            //EXIT(FALSE);
            Myresult := CreateJsonPayload('0', 'False', ErrText);
            exit(Myresult);
        END;
    END;



    //*********************** ValidateReturnOrder *********************
    PROCEDURE ValidateReturnOrder(inputJson: Text[2024]): Text[1024]
    var
        //Function In
        ReturnOrderNo: Code[30];

        //Function Out
        ErrText: Text[250];
        Flag: Boolean;

        input: JsonObject;
        c: JsonToken;
        Myresult: Text[1024];
        Orderjson: JsonObject;

    BEGIN

        input.ReadFrom(inputJson);
        //Get ReturnOrderNo
        if input.Get('ReturnOrderNo', c) then begin
            ReturnOrderNo := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'ReturnOrderNo Node not found in Payload');
            exit(Myresult);
        end;


        SalesHeaderRec.RESET;
        IF NOT SalesHeaderRec.GET(SalesHeaderRec."Document Type"::"Return Order", ReturnOrderNo) THEN BEGIN
            ErrText := 'Selected GR Does not exist';
            //EXIT(FALSE);
            Myresult := CreateJsonPayload('0', 'False', ErrText);
            exit(Myresult);

        END ELSE BEGIN
            IF (SalesHeaderRec."Assigned User ID" = '') THEN BEGIN
                SalesHeaderRec."Assigned User ID" := USERID;
                SalesHeaderRec.MODIFY(TRUE);
                //EXIT(TRUE);
                Myresult := CreateJsonPayload('1', 'True', ErrText);
                exit(Myresult);

            END ELSE BEGIN
                //EXIT(TRUE);
                Myresult := CreateJsonPayload('1', 'True', ErrText);
                exit(Myresult);
            END;
        END;
    END;

    //*********************** ValidateReturnBarcode *********************
    PROCEDURE ValidateReturnBarcode(inputJson: Text[2024]): Text[1024]
    var
        //Function In
        RtrnBarcode: Code[30];
        RtrnOrderNo: Code[30];

        //Function Out
        ItemCode: Code[30];
        VariantCode: Code[30];
        UOM: Code[10];
        ItmCatalogCode: Code[30];
        ErrText: Text[250];
        flag: Boolean;


        input: JsonObject;
        c: JsonToken;
        Myresult: Text[1024];
        Orderjson: JsonObject;


    BEGIN

        input.ReadFrom(inputJson);
        //Get RtrnBarcode
        if input.Get('RtrnBarcode', c) then begin
            RtrnBarcode := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'RtrnBarcode Node not found in Payload');
            exit(Myresult);
        end;

        //Get RtrnOrderNo
        if input.Get('RtrnOrderNo', c) then begin
            RtrnBarcode := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'RtrnOrderNo Node not found in Payload');
            exit(Myresult);
        end;

        IF NOT BSNO.GET(RtrnBarcode) THEN BEGIN
            ErrText := 'Selected Barcode Does not exist in Barcode Serial No. Table ';
            //EXIT(FALSE);
            Myresult := CreateJsonPayload('0', 'False', ErrText);
            exit(Myresult);
        END;


        IF BSNO.GRNo = RtrnOrderNo THEN BEGIN
            ErrText := 'Selected Barcode (' + RtrnBarcode + ') Already Return ';
            //EXIT(FALSE);
            Myresult := CreateJsonPayload('0', 'False', ErrText);
            exit(Myresult);
        END;

        IF BSNO."Parent Serial No." = '' THEN BEGIN
            ErrText := 'Barcode ' + RtrnBarcode + 'is not sale you are returning this item';
            //EXIT(FALSE);
            Myresult := CreateJsonPayload('0', 'False', ErrText);
            exit(Myresult);
        END;


        ItemCode := BSNO."Item Code";
        UOM := BSNO."Base Unit of Measure";
        VariantCode := BSNO."Variant Code";
        ItmCatalogCode := BSNO."Item Category Code";
        ErrText := '';
        //EXIT(TRUE);
        Orderjson.Add('id', '1');
        Orderjson.Add('Success', 'True');
        Orderjson.Add('Message', '');
        Orderjson.Add('ItemCode', ItemCode);
        Orderjson.Add('VariantCode', VariantCode);
        Orderjson.Add('UOM', UOM);
        Orderjson.Add('ItmCatalogCode', ItmCatalogCode);
        Orderjson.WriteTo(Myresult);
        exit(Myresult);
    END;

    //*********************** GoodsReturn *********************

    PROCEDURE GoodsReturn(inputJson: Text[2024]): Text[1024]
    var
        //Function In
        RtrnBarcode: Code[30];
        RtrnOrderNo: Code[30];

        //Function Out
        ErrText: Text[1024];
        flg: Boolean;

        BSNORec: Record "Barcode Serial No.";
        SalesPriceRec: Record "Sales Price";
        SalesPriceMRP: Decimal;
        CustRec: Record "Customer";
        ItemRec: Record "Item";
        SalesLineRec: Record "Sales Line";

        input: JsonObject;
        c: JsonToken;
        Myresult: Text[1024];
        Orderjson: JsonObject;


    BEGIN

        input.ReadFrom(inputJson);
        //Get RtrnBarcode
        if input.Get('RtrnBarcode', c) then begin
            RtrnBarcode := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'RtrnBarcode Node not found in Payload');
            exit(Myresult);
        end;

        //Get RtrnOrderNo
        if input.Get('RtrnOrderNo', c) then begin
            RtrnOrderNo := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'RtrnOrderNo Node not found in Payload');
            exit(Myresult);
        end;


        SalesLineRec.RESET;
        SalesLineRec.SETCURRENTKEY("Document Type", "Document No.", "Line No.");
        SalesLineRec.SETRANGE(SalesLineRec."Document Type", SalesLineRec."Document Type"::"Return Order");
        SalesLineRec.SETRANGE(SalesLineRec."Document No.", RtrnOrderNo);
        IF SalesLineRec.FINDLAST THEN
            LastEntryNo := SalesLineRec."Line No."
        ELSE
            LastEntryNo := 10000;

        BSNO.GET(RtrnBarcode);

        SalesPriceMRP := 0;

        CustRec.GET(BSNO."Sell to Customer No.");

        SalesPriceRec.RESET;
        SalesPriceRec.SETRANGE("Sales Code", CustRec."Customer Price Group");
        SalesPriceRec.SETRANGE("Item No.", BSNO."Item Code");
        SalesPriceRec.SETRANGE("Variant Code", BSNO."Variant Code");
        IF SalesPriceRec.FINDLAST THEN BEGIN
            IF SalesPriceRec."Unit of Measure Code" = 'DOZ' THEN BEGIN
                IF SalesPriceRec."MRP Price" <> 0 THEN
                    SalesPriceMRP := SalesPriceRec."MRP Price" / 12;
            END ELSE BEGIN
                SalesPriceMRP := SalesPriceRec."MRP Price";
            END;
        END;

        IF SalesPriceMRP = BSNO.MRP THEN BEGIN
            //MESSAGE('%1-%2-%3-%4',BSNO.MRP,BSNO."Item Code",BSNO."Variant Code",SalesPriceMRP);
            SalesLineRec.INIT;
            SalesLineRec.VALIDATE("Document Type", SalesLineRec."Document Type"::"Return Order");
            SalesLineRec.VALIDATE("Document No.", RtrnOrderNo);
            SalesLineRec.VALIDATE("Line No.", LastEntryNo + 1);
            SalesLineRec.VALIDATE(Type, SalesLineRec.Type::Item);
            SalesLineRec.VALIDATE("No.", BSNO."Item Code");
            SalesLineRec.VALIDATE("Variant Code", BSNO."Variant Code");
            IF ItemRec.GET(BSNO."Item Code") THEN;
            SalesLineRec.VALIDATE("Unit of Measure Code", ItemRec."Sales Unit of Measure");

            IF (ItemRec."Sales Unit of Measure" = 'DOZ') AND (BSNO."Base Unit of Measure" = 'DOZ') THEN BEGIN
                SalesLineRec.VALIDATE(Quantity, BSNO."Quantity (Base)");
                //ItemJournalLineTemp.VALIDATE("Qty. to Ship", BSNO."Quantity (Base)");
            END ELSE
                IF (ItemRec."Sales Unit of Measure" = 'PCS') AND (BSNO."Base Unit of Measure" = 'PCS') THEN BEGIN
                    SalesLineRec.VALIDATE(Quantity, BSNO."Quantity (Base)");
                    //ItemJournalLineTemp.VALIDATE("Qty. to Ship", BSNO."Quantity (Base)");
                END ELSE
                    IF (ItemRec."Sales Unit of Measure" = 'DOZ') AND (BSNO."Base Unit of Measure" = 'PCS') THEN BEGIN
                        SalesLineRec.VALIDATE(Quantity, BSNO."Quantity (Base)" / 12);
                        //ItemJournalLineTemp.VALIDATE("Qty. to Ship", BSNO."Quantity (Base)"/12);
                    END;


            //SalesLineRec.VALIDATE("Quantity (Base)",BSNO."Quantity (Base)");
            SalesLineRec.INSERT(TRUE);

            IF BSNORec.GET(RtrnBarcode) THEN BEGIN
                BSNORec."Parent Serial No." := '';
                BSNORec.Status := BSNORec.Status::"Goods Return";
                BSNORec."Blanket Order No." := '';
                BSNORec."Blanket Order Line No." := LastEntryNo + 1;
                BSNORec."Carton Packed By" := '';
                BSNORec."Carton Packing Date" := 0D;
                BSNORec.GRNo := RtrnOrderNo;
                BSNORec.Tracking := BSNORec.Tracking::"Goods Return";
                BSNORec.MODIFY(TRUE);
            END;
        END ELSE BEGIN
            ErrText := 'Value is not same as Customer price Group MRP';
            //EXIT(FALSE);
            Myresult := CreateJsonPayload('0', 'False', ErrText);
            exit(Myresult);
        END;

        ErrText := '';
        //EXIT(TRUE);
        Myresult := CreateJsonPayload('1', 'True', ErrText);
        exit(Myresult);
    END;


}