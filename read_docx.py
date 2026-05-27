import zipfile
import xml.etree.ElementTree as ET
import os

def extract_docx_text(docx_path, txt_path):
    WORD_NAMESPACE = '{http://schemas.openxmlformats.org/wordprocessingml/2006/main}'
    PARA = WORD_NAMESPACE + 'p'
    TEXT = WORD_NAMESPACE + 't'
    TABLE = WORD_NAMESPACE + 'tbl'
    ROW = WORD_NAMESPACE + 'tr'
    CELL = WORD_NAMESPACE + 'tc'

    if not os.path.exists(docx_path):
        print(f"Error: {docx_path} does not exist")
        return

    with zipfile.ZipFile(docx_path) as docx:
        if 'word/document.xml' not in docx.namelist():
            print("Error: word/document.xml not found in docx")
            return
        
        tree = ET.parse(docx.open('word/document.xml'))
        root = tree.getroot()
        
        out_lines = []
        body = root.find(f'{WORD_NAMESPACE}body')
        if body is None:
            body = root

        for child in body:
            tag = child.tag
            if tag == PARA:
                texts = [node.text for node in child.iter(TEXT) if node.text]
                if texts:
                    out_lines.append("".join(texts))
                else:
                    out_lines.append("")
            elif tag == TABLE:
                out_lines.append("--- TABLE START ---")
                for row in child.iter(ROW):
                    row_texts = []
                    for cell in row.iter(CELL):
                        cell_para_texts = []
                        for para in cell.iter(PARA):
                            p_text = "".join(node.text for node in para.iter(TEXT) if node.text)
                            if p_text:
                                cell_para_texts.append(p_text)
                        cell_text = " / ".join(cell_para_texts)
                        row_texts.append(cell_text)
                    out_lines.append(" | ".join(row_texts))
                out_lines.append("--- TABLE END ---")

        # Fallback if body child iteration yielded empty text
        if not out_lines or len("".join(out_lines).strip()) == 0:
            for paragraph in root.iter(PARA):
                texts = [node.text for node in paragraph.iter(TEXT) if node.text]
                if texts:
                    out_lines.append("".join(texts))
                else:
                    out_lines.append("")
                    
        with open(txt_path, 'w', encoding='utf-8') as f:
            f.write("\n".join(out_lines))
        print(f"Successfully extracted text to {txt_path}")

if __name__ == '__main__':
    extract_docx_text('VacanSee_SDE.docx', 'VacanSee_SDE_text.txt')
