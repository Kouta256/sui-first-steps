module barberia::registro_barberia {
    use std::string::{String, utf8};
    use sui::vec_map::{Self, VecMap};
   

    // Objeto principal Barberia que almacena nombre y un VecMap del dueño ID al Cliente
    public struct Barberia has key, store {
        id: UID,
        nombre_barberia: String,
        clientes: VecMap<u64, Cliente>,
    }

    // Cliente con nombre y vector de servicios tomados
    public struct Cliente has copy, drop, store {
        nombre_cliente: String,
        servicios_tomados: vector<ServicioTomado>,
    }

    // Enum para servicios tomados: Corte, Afeitado, Delineado.
    public enum ServicioTomado has store, drop, copy {
        Corte(Corte),
        Afeitado(Afeitado),
        Delineado(Delineado),
    }

    // Estructura Corte con duración en minutos y precio
    public struct Corte has copy, drop, store {
        duracion_minutos: u64,
        precio: u64,
    }

    // Estructura Delineado con tipo de afeitado y precio
    public struct Afeitado has copy, drop, store {
        tipo: String,
        precio: u64,
    }

    // Estructura Afeitado con tipo de afeitado y precio
    public struct Delineado has copy, drop, store {
        tipo: String,
        precio: u64,
    }

    #[error]
    const ID_YA_EXISTE: vector<u8> = b"ERROR el id ya existe";
    #[error]
    const ID_NO_EXISTE: vector<u8> = b"ERROR el id no existe";

    
    public fun crear_barberia(nombre: String, ctx: &mut TxContext) {
        let barberia = Barberia {
            id: object::new(ctx),
            nombre_barberia: nombre,
            clientes: vec_map::empty(),
        };
        transfer::transfer(barberia, tx_context::sender(ctx));
    }

    public fun agregar_cliente(barberia: &mut Barberia, id_cliente: u64, nombre_cliente: String) {
        assert!(!barberia.clientes.contains(&id_cliente), ID_YA_EXISTE);
        let cliente = Cliente {
            nombre_cliente,
            servicios_tomados: vector[],
        };
        barberia.clientes.insert(id_cliente, cliente);
    }

    public fun agregar_corte(barberia: &mut Barberia, id_cliente: u64, duracion_minutos: u64, precio: u64) {
        assert!(barberia.clientes.contains(&id_cliente), ID_NO_EXISTE);

        let nuevo_servicio = ServicioTomado::Corte(Corte { duracion_minutos, precio });

        let cliente_ref = barberia.clientes.get_mut(&id_cliente);
        cliente_ref.servicios_tomados.push_back(nuevo_servicio);
    }

    public fun agregar_afeitado(barberia: &mut Barberia, id_cliente: u64, tipo: String, precio: u64) {
        assert!(barberia.clientes.contains(&id_cliente), ID_NO_EXISTE);

        let nuevo_servicio = ServicioTomado::Afeitado(Afeitado { tipo, precio });

        let cliente_ref = barberia.clientes.get_mut(&id_cliente);
        cliente_ref.servicios_tomados.push_back(nuevo_servicio);
    }

    public fun modificar_servicio(barberia: &mut Barberia, id_cliente: u64, indice_servicio: u64, nuevo_nombre: String, nuevo_precio: u64) {

        //Verificar que el cliente exista
        assert!(barberia.clientes.contains(&id_cliente), ID_NO_EXISTE);

        //Obtener referencia mutable al cliente
        let cliente_ref = barberia.clientes.get_mut(&id_cliente);

        //Verificar que el índice del servicio sea válido
        assert!(indice_servicio < vector::length(&cliente_ref.servicios_tomados), ID_NO_EXISTE);

        let servicio_ref = cliente_ref.servicios_tomados.borrow_mut(indice_servicio);

        match (servicio_ref) {
            ServicioTomado::Corte(corte) => {
                corte.precio = nuevo_precio;
            },
            ServicioTomado::Afeitado(afeitado) => {
                afeitado.tipo = nuevo_nombre;
                afeitado.precio = nuevo_precio;
            },
            ServicioTomado::Delineado(delineado) => {
                delineado.tipo = nuevo_nombre;
                delineado.precio = nuevo_precio;
            }
        }
    }
}
