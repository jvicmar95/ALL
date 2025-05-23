import sqlite3
import os

BASE_DIR = os.path.dirname(__file__)
DATA_DIR = os.path.join(BASE_DIR, 'data')
DB_FILE = os.path.join(DATA_DIR, 'tareas.db')

def init_db():
    os.makedirs(DATA_DIR, exist_ok=True)
    conn = sqlite3.connect(DB_FILE)
    c = conn.cursor()
    c.execute("""
        CREATE TABLE IF NOT EXISTS tareas (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            texto TEXT NOT NULL,
            completada INTEGER DEFAULT 0,
            nota TEXT DEFAULT '',
            estado TEXT DEFAULT 'pendiente',
            fecha_creacion TEXT DEFAULT CURRENT_TIMESTAMP,
            fecha_limite TEXT DEFAULT NULL,
            etiqueta TEXT DEFAULT ''
        )
    """)
    conn.commit()
    conn.close()

def obtener_tareas():
    with sqlite3.connect(DB_FILE) as conn:
        c = conn.cursor()
        c.execute("SELECT id, texto, completada, nota, estado, fecha_creacion, fecha_limite, etiqueta FROM tareas ORDER BY id DESC")
        tareas = [
            dict(
                id=row[0],
                texto=row[1],
                completada=bool(row[2]),
                nota=row[3],
                estado=row[4],
                fecha=row[5],
                fecha_limite=row[6],
                etiqueta=row[7]
            ) for row in c.fetchall()
        ]
        return tareas

def agregar_tarea(texto, etiqueta):
    with sqlite3.connect(DB_FILE) as conn:
        c = conn.cursor()
        c.execute("INSERT INTO tareas (texto, etiqueta) VALUES (?, ?)", (texto.strip(), etiqueta.strip()))
        conn.commit()

def eliminar_tarea(tarea_id):
    with sqlite3.connect(DB_FILE) as conn:
        c = conn.cursor()
        c.execute("DELETE FROM tareas WHERE id = ?", (tarea_id,))
        conn.commit()

def cambiar_estado(tarea_id, nuevo_estado):
    with sqlite3.connect(DB_FILE) as conn:
        c = conn.cursor()
        c.execute("UPDATE tareas SET estado = ? WHERE id = ?", (nuevo_estado, tarea_id))
        conn.commit()

def editar_tarea(tarea_id, nuevo_texto):
    with sqlite3.connect(DB_FILE) as conn:
        c = conn.cursor()
        c.execute("UPDATE tareas SET texto = ? WHERE id = ?", (nuevo_texto.strip(), tarea_id))
        conn.commit()

def actualizar_nota(tarea_id, nota):
    with sqlite3.connect(DB_FILE) as conn:
        c = conn.cursor()
        c.execute("UPDATE tareas SET nota = ? WHERE id = ?", (nota.strip(), tarea_id))
        conn.commit()

def actualizar_fecha_limite(tarea_id, fecha_limite):
    with sqlite3.connect(DB_FILE) as conn:
        c = conn.cursor()
        c.execute("UPDATE tareas SET fecha_limite = ? WHERE id = ?", (fecha_limite, tarea_id))
        conn.commit()

def actualizar_etiqueta(tarea_id, nueva_etiqueta):
    with sqlite3.connect(DB_FILE) as conn:
        c = conn.cursor()
        c.execute("UPDATE tareas SET etiqueta = ? WHERE id = ?", (nueva_etiqueta, tarea_id))
        conn.commit()
