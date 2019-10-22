# Last Tested Version 1.8.1


import logging
import azure.functions as func
from azure.storage.blob import BlockBlobService
import os, io
import json
import base64
from pyzbar.pyzbar import decode
from PIL import Image
from sugarcrm.client import Client
import base64

SugarURL = os.environ['SugarURL']
SugarUser = os.environ['SugarUser']
SugarPassword = os.environ['SugarPassword']



def main(myblob: func.InputStream):
    logging.info(f"Python blob trigger function processed blob \n"
                 f"Name: {myblob.name}\n"
                 f"Blob Size: {myblob.length} bytes")
    file = myblob.read()
    image = io.BytesIO(file)    
    barcode=decode(Image.open(image))
    

    for obj in barcode:
        
        client = Client(SugarURL, SugarUser, SugarPassword)

        item = {'Name': obj.data.decode() }

 
        Note = client.set_entry('Notes', item)
        Debitor = client.search_by_module(obj.data.decode(), ['DEB_Debitoren'])

        try:
            relation = client.set_relationship('DEB_Debitoren', Debitor['entry_list'][0]['records'][0]['id']['value'],'deb_debitoren_notes_1', [Note['id']])
        except:
            print ("Cloud not find")
   
        image = io.BytesIO(file)   
        encoded_string = base64.b64encode(image.getvalue())
        encoded_string = encoded_string.decode()
        #logging.info(f"Upload \n"
        #         f"Name: {myblob.name}\n"
        #         f"Base64: {encoded_string}")
        client.set_note_attachment(Note['id'], myblob.name, encoded_string)
