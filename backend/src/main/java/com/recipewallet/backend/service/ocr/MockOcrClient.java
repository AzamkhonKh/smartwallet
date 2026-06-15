package com.recipewallet.backend.service.ocr;

import org.springframework.web.multipart.MultipartFile;
import java.io.IOException;

public class MockOcrClient implements OcrClient {

    @Override
    public String extractText(MultipartFile file) throws IOException {
        String filename = file.getOriginalFilename() != null ? file.getOriginalFilename().toLowerCase() : "";

        if (filename.contains("starbucks") || filename.contains("coffee") || filename.contains("latte")) {
            return "STARBUCKS COFFEE\nStore #48293\n\n1 LATTE       4.75\n1 CROISSANT   3.85\n1 MACCHIATO   5.25\n\nSUBTOTAL:    13.85\nTAX:          0.00\nTOTAL:       13.85\n\nTHANK YOU!";
        } else if (filename.contains("foods") || filename.contains("grocery") || filename.contains("groceries") || filename.contains("market")) {
            return "WHOLE FOODS MARKET\n\nORGANIC MILK      5.99\nSTRAWBERRIES      4.49\nWHEAT BREAD       3.49\nEGGS              4.99\nAVOCADO           1.99\n\nTOTAL AMOUNT:    20.95\nITEMS COUNT:       5\n\nHAVE A NICE DAY!";
        } else if (filename.contains("utility") || filename.contains("electricity") || filename.contains("pge") || filename.contains("power")) {
            return "PACIFIC GAS & ELECTRIC COMPANY\nAccount: 94829-23\n\nMONTHLY CHARGES (MAY 2026)\nElectricity Usage: 84.20\n\nTOTAL DUE: $84.20\nPAYMENT DUE BY: 06/25/2026";
        } else if (filename.contains("target") || filename.contains("walmart") || filename.contains("shopping")) {
            return "TARGET STORES\n\nT-SHIRT           18.00\nHEADPHONES        25.00\nSALES TAX          2.50\n\nTOTAL:           45.50\nCARD AUTH: 04928A";
        } else {
            // General Fallback with a fixed mock price for test predictability, or dynamically generated
            double fallbackPrice = 24.99;
            return "MERCHANT RECEIPT\n\nMISC ITEMS       " + fallbackPrice + "\n\nTOTAL AMOUNT:    " + fallbackPrice + "\n\nMERCHANT ID: 948293";
        }
    }
}
