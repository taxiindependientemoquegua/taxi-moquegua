// server.cjs
const express = require('express');
const cors = require('cors');
const supabase = require('./supabaseClient');

const app = express();
app.use(cors());
app.use(express.json());

// Ruta de salud
app.get('/health', (req, res) => {
  res.json({ status: 'ok', supabase: 'connected' });
});

// Ruta para obtener todos los viajes
app.get('/trips', async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('trips')
      .select('*')
      .order('created_at', { ascending: false });

    if (error) {
      console.error('Error al obtener viajes:', error.message);
      return res.status(500).json({ error: error.message });
    }

    // Validar que data no sea null
    if (!data) {
      return res.status(500).json({ error: 'No se pudieron obtener los viajes' });
    }

    res.json(data);
  } catch (error) {
    console.error('Error inesperado al obtener viajes:', error.message);
    res.status(500).json({ error: error.message });
  }
});

// Ruta para crear un nuevo viaje
app.post('/trips', async (req, res) => {
  try {
    const { 
      client_id, 
      origin_name, 
      destination_name, 
      origin_point, 
      destination_point, 
      service_type, 
      proposed_price, 
      payment_method 
    } = req.body;

    // Validar que el cliente exista
    const { data: client, error: clientError } = await supabase
      .from('users')
      .select('id')
      .eq('id', client_id)
      .single();

    if (clientError || !client) {
      return res.status(400).json({ error: 'Cliente no encontrado' });
    }

    // Convertir puntos a formato PostGIS
    const originPointStr = `POINT(${origin_point.lng} ${origin_point.lat})`;
    const destPointStr = `POINT(${destination_point.lng} ${destination_point.lat})`;

    // Insertar SIN exigir .select()
    const { error: insertError } = await supabase
      .from('trips')
      .insert([{
        client_id: client.id,
        origin_name,
        destination_name,
        origin_point: originPointStr,
        destination_point: destPointStr,
        service_type,
        proposed_price,
        payment_method,
        status: 'pending'
      }]);

    if (insertError) {
      console.error('Error en inserción:', insertEror.message);
      return res.status(500).json({ error: insertError.message });
    }

    // Confirmar éxito
    return res.status(201).json({ success: true, message: 'Solicitud creada' });

  } catch (error) {
    console.error('Error inesperado al crear viaje:', error.message);
    return res.status(500).json({ error: error.message });
  }
});

const PORT = process.env.BACKEND_PORT || 3000;

// Ruta raíz
app.get('/', (req, res) => {
  res.json({ message: 'Bienvenido a TAXI MOQUEGUA API', status: 'ok' });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`✅ Servidor corriendo en http://localhost:${PORT}`);
});
