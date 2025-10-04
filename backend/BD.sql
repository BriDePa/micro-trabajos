-- =============================================
-- BASE DE DATOS MEJORADA - AYUDITA PLATFORM
-- Adaptada para MariaDB con mejoras estructurales
-- =============================================

-- Eliminar tablas existentes
DROP TABLE IF EXISTS mensajes;
DROP TABLE IF EXISTS calificaciones;
DROP TABLE IF EXISTS reportes;
DROP TABLE IF EXISTS postulaciones;
DROP TABLE IF EXISTS favor_categorias;
DROP TABLE IF EXISTS favores;
DROP TABLE IF EXISTS categorias;
DROP TABLE IF EXISTS trabajadores;
DROP TABLE IF EXISTS usuarios;

-- =============================================
-- TABLAS PRINCIPALES
-- =============================================

CREATE TABLE usuarios (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    nombre_completo VARCHAR(100) NOT NULL,
    telefono VARCHAR(20),
    avatar_url VARCHAR(500),
    tipo ENUM('solicitante', 'trabajador', 'ambos') NOT NULL DEFAULT 'solicitante',
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP,
    ultima_conexion DATETIME,
    activo TINYINT(1) DEFAULT 1,
    INDEX idx_email (email),
    INDEX idx_tipo (tipo),
    INDEX idx_activo (activo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE trabajadores (
    trabajador_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNIQUE NOT NULL,
    descripcion TEXT,
    habilidades JSON,
    experiencia TEXT,
    tarifa_horaria DECIMAL(10,2),
    tarifa_minima DECIMAL(10,2),
    tarifa_maxima DECIMAL(10,2),
    disponible TINYINT(1) DEFAULT 1,
    promedio_calificacion DECIMAL(3,2) DEFAULT 0.00,
    total_trabajos INT DEFAULT 0,
    total_completados INT DEFAULT 0,
    tasa_completacion DECIMAL(5,2) DEFAULT 0.00,
    verificado TINYINT(1) DEFAULT 0,
    fecha_verificacion DATETIME,
    FOREIGN KEY (user_id) REFERENCES usuarios(user_id) ON DELETE CASCADE,
    INDEX idx_disponible (disponible),
    INDEX idx_calificacion (promedio_calificacion),
    INDEX idx_verificado (verificado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE categorias (
    categoria_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL,
    descripcion TEXT,
    icono VARCHAR(50),
    activa TINYINT(1) DEFAULT 1,
    orden INT DEFAULT 0,
    parent_id INT,
    FOREIGN KEY (parent_id) REFERENCES categorias(categoria_id) ON DELETE SET NULL,
    INDEX idx_activa (activa),
    INDEX idx_parent (parent_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE favores (
    favor_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    titulo VARCHAR(200) NOT NULL,
    descripcion TEXT NOT NULL,
    ubicacion VARCHAR(200),
    latitud DECIMAL(10, 8),
    longitud DECIMAL(11, 8),
    es_virtual TINYINT(1) DEFAULT 0,
    fecha_limite DATETIME,
    presupuesto_min DECIMAL(10,2),
    presupuesto_max DECIMAL(10,2),
    duracion_estimada INT COMMENT 'Duración en minutos',
    urgente TINYINT(1) DEFAULT 0,
    estado ENUM('abierto', 'asignado', 'en_progreso', 'completado', 'cancelado') DEFAULT 'abierto',
    trabajador_asignado_id INT,
    fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fecha_asignacion DATETIME,
    fecha_completado DATETIME,
    vistas INT DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES usuarios(user_id) ON DELETE CASCADE,
    FOREIGN KEY (trabajador_asignado_id) REFERENCES trabajadores(trabajador_id) ON DELETE SET NULL,
    INDEX idx_estado (estado),
    INDEX idx_user (user_id),
    INDEX idx_fecha (fecha_creacion),
    INDEX idx_ubicacion (latitud, longitud),
    INDEX idx_urgente (urgente),
    INDEX idx_trabajador (trabajador_asignado_id),
    FULLTEXT idx_busqueda (titulo, descripcion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE favor_categorias (
    favor_id INT NOT NULL,
    categoria_id INT NOT NULL,
    PRIMARY KEY (favor_id, categoria_id),
    FOREIGN KEY (favor_id) REFERENCES favores(favor_id) ON DELETE CASCADE,
    FOREIGN KEY (categoria_id) REFERENCES categorias(categoria_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE postulaciones (
    postulacion_id INT AUTO_INCREMENT PRIMARY KEY,
    favor_id INT NOT NULL,
    trabajador_id INT NOT NULL,
    mensaje TEXT NOT NULL,
    propuesta_presupuesto DECIMAL(10,2),
    tiempo_estimado INT COMMENT 'Tiempo estimado en minutos',
    estado ENUM('pendiente', 'aceptada', 'rechazada', 'retirada') DEFAULT 'pendiente',
    fecha_postulacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    fecha_respuesta DATETIME,
    UNIQUE KEY unique_postulacion (favor_id, trabajador_id),
    FOREIGN KEY (favor_id) REFERENCES favores(favor_id) ON DELETE CASCADE,
    FOREIGN KEY (trabajador_id) REFERENCES trabajadores(trabajador_id) ON DELETE CASCADE,
    INDEX idx_estado (estado),
    INDEX idx_trabajador (trabajador_id),
    INDEX idx_fecha (fecha_postulacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE mensajes (
    mensaje_id INT AUTO_INCREMENT PRIMARY KEY,
    favor_id INT NOT NULL,
    remitente_id INT NOT NULL,
    destinatario_id INT NOT NULL,
    contenido TEXT NOT NULL,
    tipo ENUM('texto', 'sistema', 'imagen', 'archivo') DEFAULT 'texto',
    archivo_url VARCHAR(500),
    fecha_envio DATETIME DEFAULT CURRENT_TIMESTAMP,
    leido TINYINT(1) DEFAULT 0,
    fecha_leido DATETIME,
    FOREIGN KEY (favor_id) REFERENCES favores(favor_id) ON DELETE CASCADE,
    FOREIGN KEY (remitente_id) REFERENCES usuarios(user_id) ON DELETE CASCADE,
    FOREIGN KEY (destinatario_id) REFERENCES usuarios(user_id) ON DELETE CASCADE,
    INDEX idx_favor (favor_id),
    INDEX idx_fecha (fecha_envio),
    INDEX idx_leido (leido),
    INDEX idx_destinatario (destinatario_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE calificaciones (
    calificacion_id INT AUTO_INCREMENT PRIMARY KEY,
    favor_id INT UNIQUE NOT NULL,
    usuario_calificador_id INT NOT NULL,
    usuario_calificado_id INT NOT NULL,
    tipo_calificacion ENUM('trabajador', 'solicitante') NOT NULL,
    puntuacion INT NOT NULL CHECK (puntuacion BETWEEN 1 AND 5),
    puntualidad INT CHECK (puntualidad BETWEEN 1 AND 5),
    calidad INT CHECK (calidad BETWEEN 1 AND 5),
    comunicacion INT CHECK (comunicacion BETWEEN 1 AND 5),
    comentario TEXT,
    fecha_calificacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    respuesta TEXT COMMENT 'Respuesta a la calificación',
    fecha_respuesta DATETIME,
    FOREIGN KEY (favor_id) REFERENCES favores(favor_id) ON DELETE CASCADE,
    FOREIGN KEY (usuario_calificador_id) REFERENCES usuarios(user_id) ON DELETE CASCADE,
    FOREIGN KEY (usuario_calificado_id) REFERENCES usuarios(user_id) ON DELETE CASCADE,
    INDEX idx_calificado (usuario_calificado_id),
    INDEX idx_tipo (tipo_calificacion),
    INDEX idx_fecha (fecha_calificacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE reportes (
    reporte_id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_reportador_id INT NOT NULL,
    usuario_reportado_id INT,
    favor_id INT,
    tipo ENUM('spam', 'contenido_inapropiado', 'fraude', 'acoso', 'incumplimiento', 'otro') NOT NULL,
    descripcion TEXT NOT NULL,
    evidencia_url VARCHAR(500),
    estado ENUM('pendiente', 'en_revision', 'resuelto', 'desestimado') DEFAULT 'pendiente',
    fecha_reporte DATETIME DEFAULT CURRENT_TIMESTAMP,
    fecha_revision DATETIME,
    fecha_resolucion DATETIME,
    resolucion TEXT,
    admin_id INT,
    FOREIGN KEY (usuario_reportador_id) REFERENCES usuarios(user_id) ON DELETE CASCADE,
    FOREIGN KEY (usuario_reportado_id) REFERENCES usuarios(user_id) ON DELETE SET NULL,
    FOREIGN KEY (favor_id) REFERENCES favores(favor_id) ON DELETE SET NULL,
    INDEX idx_estado (estado),
    INDEX idx_reportado (usuario_reportado_id),
    INDEX idx_fecha (fecha_reporte)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- TABLA DE NOTIFICACIONES
-- =============================================

CREATE TABLE notificaciones (
    notificacion_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    tipo ENUM('nueva_postulacion', 'postulacion_aceptada', 'postulacion_rechazada', 
              'nuevo_mensaje', 'favor_completado', 'nueva_calificacion', 'recordatorio') NOT NULL,
    titulo VARCHAR(200) NOT NULL,
    mensaje TEXT NOT NULL,
    referencia_id INT COMMENT 'ID del favor, postulación, etc.',
    leida TINYINT(1) DEFAULT 0,
    fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    fecha_leida DATETIME,
    FOREIGN KEY (user_id) REFERENCES usuarios(user_id) ON DELETE CASCADE,
    INDEX idx_user_leida (user_id, leida),
    INDEX idx_fecha (fecha_creacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- TABLA DE TRANSACCIONES/PAGOS
-- =============================================

CREATE TABLE transacciones (
    transaccion_id INT AUTO_INCREMENT PRIMARY KEY,
    favor_id INT NOT NULL,
    solicitante_id INT NOT NULL,
    trabajador_id INT NOT NULL,
    monto DECIMAL(10,2) NOT NULL,
    comision DECIMAL(10,2) NOT NULL,
    monto_total DECIMAL(10,2) NOT NULL,
    metodo_pago ENUM('tarjeta', 'transferencia', 'efectivo', 'billetera') NOT NULL,
    estado ENUM('pendiente', 'procesando', 'completada', 'fallida', 'reembolsada') DEFAULT 'pendiente',
    referencia_externa VARCHAR(255),
    fecha_transaccion DATETIME DEFAULT CURRENT_TIMESTAMP,
    fecha_completada DATETIME,
    FOREIGN KEY (favor_id) REFERENCES favores(favor_id) ON DELETE CASCADE,
    FOREIGN KEY (solicitante_id) REFERENCES usuarios(user_id) ON DELETE CASCADE,
    FOREIGN KEY (trabajador_id) REFERENCES trabajadores(trabajador_id) ON DELETE CASCADE,
    INDEX idx_favor (favor_id),
    INDEX idx_estado (estado),
    INDEX idx_fecha (fecha_transaccion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- DATOS INICIALES
-- =============================================

INSERT INTO categorias (nombre, descripcion, icono, orden) VALUES
('Educación', 'Servicios educativos y de formación', 'school', 1),
('Tecnología', 'Servicios tecnológicos y digitales', 'computer', 2),
('Diseño', 'Servicios de diseño y creatividad', 'palette', 3),
('Negocios', 'Servicios empresariales y profesionales', 'business', 4),
('Hogar', 'Servicios para el hogar', 'home', 5),
('Eventos', 'Organización y planificación de eventos', 'celebration', 6);

-- Subcategorías
INSERT INTO categorias (nombre, descripcion, icono, parent_id, orden) VALUES
('Clases Particulares', 'Tutorías y enseñanza de cualquier materia', 'school', 1, 1),
('Traducción', 'Servicios de traducción de idiomas', 'translate', 1, 2),
('Reparaciones Técnicas', 'Reparación de equipos electrónicos', 'build', 2, 1),
('Programación', 'Desarrollo de software y aplicaciones', 'code', 2, 2),
('Marketing Digital', 'Redes sociales, SEO, publicidad online', 'trending_up', 2, 3),
('Diseño Gráfico', 'Diseño de logos, banners, material gráfico', 'design_services', 3, 1),
('Diseño Web', 'Diseño de sitios web y UX/UI', 'web', 3, 2),
('Asesoría Legal', 'Consultoría y asesoramiento legal', 'gavel', 4, 1),
('Contabilidad', 'Servicios contables y financieros', 'calculate', 4, 2),
('Redacción', 'Escritura de textos y artículos', 'edit', 4, 3),
('Limpieza', 'Servicios de limpieza del hogar', 'cleaning_services', 5, 1),
('Jardinería', 'Mantenimiento de jardines', 'yard', 5, 2);

-- =============================================
-- DATOS DE PRUEBA
-- =============================================

-- Usuarios solicitantes
INSERT INTO usuarios (email, password_hash, nombre_completo, telefono, tipo, ultima_conexion, activo) VALUES
('juan.perez@email.com', '$2y$10$abcdefghijklmnopqrstuv', 'Juan Pérez López', '+591-70123456', 'solicitante', NOW(), 1),
('maria.garcia@email.com', '$2y$10$bcdefghijklmnopqrstuvw', 'María García Flores', '+591-71234567', 'solicitante', NOW(), 1),
('carlos.rodriguez@email.com', '$2y$10$cdefghijklmnopqrstuvwx', 'Carlos Rodríguez Mamani', '+591-72345678', 'ambos', NOW(), 1),
('ana.martinez@email.com', '$2y$10$defghijklmnopqrstuvwxy', 'Ana Martínez Quispe', '+591-73456789', 'solicitante', NOW(), 1),
('pedro.lopez@email.com', '$2y$10$efghijklmnopqrstuvwxyz', 'Pedro López Condori', '+591-74567890', 'solicitante', NOW(), 1);

-- Usuarios trabajadores
INSERT INTO usuarios (email, password_hash, nombre_completo, telefono, tipo, ultima_conexion, activo) VALUES
('sofia.designer@email.com', '$2y$10$fghijklmnopqrstuvwxyza', 'Sofía Vargas Cruz', '+591-75678901', 'trabajador', NOW(), 1),
('diego.dev@email.com', '$2y$10$ghijklmnopqrstuvwxyzab', 'Diego Fernández Pinto', '+591-76789012', 'trabajador', NOW(), 1),
('lucia.teacher@email.com', '$2y$10$hijklmnopqrstuvwxyzabc', 'Lucía Morales Choque', '+591-77890123', 'trabajador', NOW(), 1),
('miguel.legal@email.com', '$2y$10$ijklmnopqrstuvwxyzabcd', 'Miguel Sánchez Apaza', '+591-78901234', 'trabajador', NOW(), 1),
('carmen.marketing@email.com', '$2y$10$jklmnopqrstuvwxyzabcde', 'Carmen Torres Mamani', '+591-79012345', 'trabajador', NOW(), 1);

-- Perfiles de trabajadores
INSERT INTO trabajadores (user_id, descripcion, habilidades, experiencia, tarifa_horaria, tarifa_minima, tarifa_maxima, disponible, promedio_calificacion, total_trabajos, total_completados, tasa_completacion, verificado, fecha_verificacion) VALUES
(6, 'Diseñadora gráfica freelance con más de 5 años de experiencia. Especializada en branding e identidad corporativa.', 
 '["Adobe Photoshop", "Illustrator", "InDesign", "Figma", "Branding"]', 
 'He trabajado con más de 50 empresas locales diseñando sus logos y material publicitario.', 
 80.00, 50.00, 150.00, 1, 4.85, 47, 45, 95.74, 1, '2024-10-15 10:30:00'),

(7, 'Desarrollador Full Stack especializado en React y Node.js. Apasionado por crear soluciones web innovadoras.', 
 '["JavaScript", "React", "Node.js", "MongoDB", "PostgreSQL", "Docker"]', 
 '3 años de experiencia desarrollando aplicaciones web para startups y pequeñas empresas.', 
 120.00, 80.00, 200.00, 1, 4.92, 32, 31, 96.88, 1, '2024-11-20 14:00:00'),

(8, 'Profesora de matemáticas y física con 8 años de experiencia. Clases personalizadas para estudiantes de secundaria y universidad.', 
 '["Matemáticas", "Física", "Cálculo", "Álgebra", "Pedagogía"]', 
 'Enseñé en colegios privados por 8 años y ahora me dedico a clases particulares.', 
 60.00, 40.00, 80.00, 1, 4.95, 120, 118, 98.33, 1, '2024-09-05 09:00:00'),

(9, 'Abogado especializado en derecho civil y laboral. Consultoría legal accesible para todos.', 
 '["Derecho Civil", "Derecho Laboral", "Contratos", "Asesoría Legal"]', 
 '10 años ejerciendo como abogado. He manejado más de 200 casos exitosamente.', 
 100.00, 80.00, 150.00, 1, 4.78, 65, 63, 96.92, 1, '2024-08-12 16:45:00'),

(10, 'Especialista en marketing digital y community manager. Ayudo a negocios a crecer en redes sociales.', 
 '["Facebook Ads", "Instagram Marketing", "Google Ads", "SEO", "Community Management"]', 
 '4 años gestionando redes sociales para pymes. Incremento promedio de seguidores del 150%.', 
 70.00, 50.00, 120.00, 1, 4.68, 38, 36, 94.74, 0, NULL);

-- Usuario Carlos también es trabajador
INSERT INTO trabajadores (user_id, descripcion, habilidades, experiencia, tarifa_horaria, tarifa_minima, tarifa_maxima, disponible, promedio_calificacion, total_trabajos, total_completados, tasa_completacion) VALUES
(3, 'Electricista certificado con experiencia en instalaciones residenciales y comerciales.', 
 '["Instalaciones eléctricas", "Reparaciones", "Mantenimiento", "Domótica"]', 
 '6 años trabajando en construcción y mantenimiento eléctrico.', 
 85.00, 60.00, 130.00, 1, 4.80, 28, 27, 96.43);

-- Favores abiertos
INSERT INTO favores (user_id, titulo, descripcion, ubicacion, latitud, longitud, es_virtual, fecha_limite, presupuesto_min, presupuesto_max, duracion_estimada, urgente, estado, vistas) VALUES
(1, 'Diseño de logo para mi emprendimiento', 'Necesito un logo profesional para mi nuevo negocio de repostería. Busco algo moderno y colorido que transmita dulzura.', 'Zona Sur, La Paz', -16.5322, -68.0853, 1, '2025-10-15', 150.00, 300.00, 300, 0, 'abierto', 23),

(2, 'Clases de matemáticas para preparación universitaria', 'Mi hijo necesita reforzamiento en cálculo y álgebra para el examen de ingreso a la universidad. Preferiblemente 3 veces por semana.', 'Sopocachi, La Paz', -16.5408, -68.1193, 0, '2025-10-20', 200.00, 350.00, 120, 1, 'abierto', 15),

(4, 'Desarrollo de sitio web para mi negocio', 'Requiero un sitio web responsive para mi tienda de artesanías. Debe incluir catálogo de productos y formulario de contacto.', NULL, NULL, NULL, 1, '2025-10-25', 800.00, 1500.00, 600, 0, 'abierto', 31),

(5, 'Asesoría legal para contrato de alquiler', 'Necesito que un abogado revise y me asesore sobre un contrato de alquiler comercial antes de firmarlo.', 'Centro, La Paz', -16.5000, -68.1500, 0, '2025-10-10', 100.00, 200.00, 90, 1, 'abierto', 8);

-- Favores asignados
INSERT INTO favores (user_id, titulo, descripcion, ubicacion, es_virtual, fecha_limite, presupuesto_min, presupuesto_max, duracion_estimada, urgente, estado, trabajador_asignado_id, fecha_asignacion, vistas) VALUES
(1, 'Campaña de marketing en redes sociales', 'Necesito impulsar mi página de Instagram con contenido orgánico y publicidad pagada por 1 mes.', NULL, 1, '2025-11-05', 400.00, 600.00, 2400, 0, 'asignado', 5, '2025-10-01 10:30:00', 42),

(3, 'Traducción de documento legal español-inglés', 'Tengo un contrato de 10 páginas que necesito traducir al inglés de manera certificada.', NULL, 1, '2025-10-12', 150.00, 250.00, 240, 0, 'en_progreso', 4, '2025-09-28 15:20:00', 19);

-- Favores completados
INSERT INTO favores (user_id, titulo, descripcion, ubicacion, es_virtual, presupuesto_min, presupuesto_max, duracion_estimada, estado, trabajador_asignado_id, fecha_creacion, fecha_asignacion, fecha_completado, vistas) VALUES
(2, 'Instalación eléctrica en mi oficina', 'Necesito instalar 6 tomacorrientes adicionales y mejorar la iluminación de mi oficina.', 'Miraflores, La Paz', 0, 300.00, 500.00, 240, 'completado', 6, '2025-09-15 08:00:00', '2025-09-16 09:00:00', '2025-09-18 17:30:00', 27),

(4, 'Diseño de flyers para evento', 'Diseñé flyers digitales e impresos para un evento corporativo de 200 personas.', NULL, 1, 100.00, 200.00, 180, 'completado', 1, '2025-09-20 11:00:00', '2025-09-21 10:00:00', '2025-09-23 14:00:00', 18);

-- Relación favores-categorías
INSERT INTO favor_categorias (favor_id, categoria_id) VALUES
(1, 6),  -- Diseño Gráfico
(2, 7),  -- Clases Particulares
(3, 8),  -- Diseño Web
(4, 14), -- Asesoría Legal
(5, 11), -- Marketing Digital
(6, 8),  -- Traducción
(7, 3),  -- Tecnología (Reparaciones)
(8, 6);  -- Diseño Gráfico

-- Postulaciones
INSERT INTO postulaciones (favor_id, trabajador_id, mensaje, propuesta_presupuesto, tiempo_estimado, estado, fecha_postulacion) VALUES
(1, 1, '¡Hola! Me encantaría diseñar el logo de tu repostería. Tengo experiencia en branding de negocios gastronómicos. Te puedo mostrar mi portafolio.', 250.00, 300, 'pendiente', '2025-10-02 09:15:00'),

(2, 3, 'Buenas tardes. Soy profesora de matemáticas con 8 años de experiencia. He preparado a muchos estudiantes para exámenes de ingreso con éxito. Puedo ir 3 veces por semana.', 300.00, 360, 'pendiente', '2025-10-02 14:30:00'),

(3, 2, 'Hola, soy desarrollador full stack. Puedo crear tu sitio web con un diseño moderno y responsive. Incluyo hosting por 1 año.', 1200.00, 600, 'pendiente', '2025-10-02 16:45:00'),

(4, 4, 'Buenos días. Soy abogado especializado en derecho civil y contratos. Puedo revisar tu documento y darte una asesoría completa.', 150.00, 90, 'pendiente', '2025-10-03 08:00:00'),

(5, 5, 'Perfecto, puedo manejar tu campaña de Instagram. Incluyo diseño de contenido y gestión de anuncios. Resultados garantizados.', 500.00, 2400, 'aceptada', '2025-09-30 11:00:00'),

(6, 4, 'Hola, ofrezco traducción certificada con sello notarial. Manejo terminología legal con precisión.', 200.00, 240, 'aceptada', '2025-09-27 13:20:00'),

(7, 6, 'Hola, soy electricista certificado. Puedo realizar la instalación eléctrica que necesitas con todos los materiales incluidos.', 400.00, 240, 'aceptada', '2025-09-15 18:30:00'),

(8, 1, 'Me gustaría diseñar los flyers de tu evento. Trabajo con formatos digitales e impresos.', 150.00, 180, 'aceptada', '2025-09-20 12:00:00');

-- Mensajes
INSERT INTO mensajes (favor_id, remitente_id, destinatario_id, contenido, tipo, fecha_envio, leido, fecha_leido) VALUES
(5, 1, 10, '¿Cuándo podrías empezar con la campaña?', 'texto', '2025-09-30 11:30:00', 1, '2025-09-30 11:35:00'),
(5, 10, 1, 'Puedo empezar mañana mismo. ¿Ya tienes las fotos de los productos?', 'texto', '2025-09-30 11:40:00', 1, '2025-09-30 12:00:00'),
(5, 1, 10, 'Sí, tengo un drive con todas las imágenes. Te paso el link.', 'texto', '2025-09-30 12:05:00', 1, '2025-09-30 12:10:00'),

(6, 3, 9, '¿El documento tiene alguna cláusula especial que deba considerar?', 'texto', '2025-09-28 16:00:00', 1, '2025-09-28 16:15:00'),
(6, 9, 3, 'Sí, hay términos técnicos sobre propiedad intelectual que necesitan precisión.', 'texto', '2025-09-28 16:20:00', 1, '2025-09-28 16:25:00'),

(7, 2, 3, '¿Puedes venir mañana a revisar el lugar?', 'texto', '2025-09-15 19:00:00', 1, '2025-09-15 19:10:00'),
(7, 3, 2, 'Claro, ¿te parece bien a las 9 AM?', 'texto', '2025-09-15 19:15:00', 1, '2025-09-15 19:20:00'),
(7, 2, 3, 'Perfecto, te espero.', 'texto', '2025-09-15 19:22:00', 1, '2025-09-15 19:25:00');

-- Calificaciones
INSERT INTO calificaciones (favor_id, usuario_calificador_id, usuario_calificado_id, tipo_calificacion, puntuacion, puntualidad, calidad, comunicacion, comentario, fecha_calificacion) VALUES
(7, 2, 3, 'trabajador', 5, 5, 5, 5, 'Excelente trabajo. Carlos es muy profesional y puntual. La instalación quedó perfecta y explicó todo detalladamente. Lo recomiendo 100%.', '2025-09-18 18:00:00'),

(8, 4, 6, 'trabajador', 5, 5, 5, 4, 'Sofía hizo un trabajo increíble con los flyers. El diseño superó mis expectativas. Muy creativa y profesional.', '2025-09-23 15:30:00');

-- Notificaciones
INSERT INTO notificaciones (user_id, tipo, titulo, mensaje, referencia_id, leida, fecha_leida) VALUES
(1, 'nueva_postulacion', 'Nueva postulación en tu favor', 'Sofía Vargas Cruz se postuló para "Diseño de logo para mi emprendimiento"', 1, 1, '2025-10-02 10:00:00'),
(2, 'nueva_postulacion', 'Nueva postulación en tu favor', 'Lucía Morales Choque se postuló para "Clases de matemáticas para preparación universitaria"', 2, 0, NULL),
(10, 'postulacion_aceptada', '¡Tu postulación fue aceptada!', 'Juan Pérez López aceptó tu postulación para "Campaña de marketing en redes sociales"', 5, 1, '2025-10-01 10:35:00'),
(1, 'nuevo_mensaje', 'Nuevo mensaje de Carmen Torres', 'Tienes un nuevo mensaje sobre "Campaña de marketing en redes sociales"', 5, 1, '2025-09-30 11:41:00'),
(3, 'favor_completado', 'Trabajo completado', 'El favor "Instalación eléctrica en mi oficina" ha sido marcado como completado', 7, 1, '2025-09-18 17:35:00'),
(6, 'nueva_calificacion', 'Nueva calificación recibida', 'Ana Martínez Quispe te ha calificado con 5 estrellas', 8, 1, '2025-09-23 15:32:00');

-- Transacciones
INSERT INTO transacciones (favor_id, solicitante_id, trabajador_id, monto, comision, monto_total, metodo_pago, estado, referencia_externa, fecha_transaccion, fecha_completada) VALUES
(7, 2, 6, 400.00, 40.00, 440.00, 'tarjeta', 'completada', 'TRX-20250918-001', '2025-09-18 17:30:00', '2025-09-18 17:35:00'),
(8, 4, 1, 150.00, 15.00, 165.00, 'transferencia', 'completada', 'TRX-20250923-002', '2025-09-23 14:00:00', '2025-09-23 14:10:00'),
(5, 1, 5, 500.00, 50.00, 550.00, 'tarjeta', 'procesando', 'TRX-20251001-003', '2025-10-01 10:30:00', NULL);

-- Reportes (ejemplo)
INSERT INTO reportes (usuario_reportador_id, usuario_reportado_id, favor_id, tipo, descripcion, estado, fecha_reporte) VALUES
(5, NULL, 3, 'spam', 'El favor parece no ser legítimo, la descripción es muy vaga y sospechosa.', 'resuelto', '2025-09-25 16:00:00');