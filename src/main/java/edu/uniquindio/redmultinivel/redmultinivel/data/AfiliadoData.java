package edu.uniquindio.redmultinivel.redmultinivel.data;

import edu.uniquindio.redmultinivel.redmultinivel.dtos.productodtos.ComisionDto;
import edu.uniquindio.redmultinivel.redmultinivel.dtos.productodtos.ProductoCarritoDto;
import edu.uniquindio.redmultinivel.redmultinivel.dtos.productodtos.ProductoDto;
import javafx.collections.ObservableList;

import java.sql.*;
import java.util.ArrayList;

public class AfiliadoData {

    public static int obtenerDescuentoPorId(int affiliateId)  {

        int salida=0;
        String query = "{? = CALL CALCULAR_AFFILIATEID(?)}";

        try(Connection conn = ConexionOracle.getConn();
            CallableStatement cstmt = conn.prepareCall(query)){

            //parametros de salida
            cstmt.registerOutParameter(1, java.sql.Types.INTEGER);

            //parametros de entrada
            cstmt.setInt(2, affiliateId);

            //se ejecuta la consulta
            cstmt.execute();

            // Obtener el valor del parámetro de salida
            salida = cstmt.getInt(1);

        } catch (SQLException e) {
            throw new RuntimeException("Error al calcular el descuento del afiliado",e);
        }

        return salida;
    }

    public static void validarCredenciales(String email, String password) {

        try (Connection connection = ConexionOracle.getConn()) {
            String sql = "{CALL login_email_affiliate(?, ?)}";
            try (CallableStatement statement = connection.prepareCall(sql)) {
                statement.setString(1, email);
                statement.setString(2, password);
                statement.execute();

            }
        } catch (SQLException e) {
            throw new RuntimeException("Error al obtener El Descuento del empleado",e);
        }
    }

    public static ArrayList<ProductoCarritoDto> obtenerDatosCarrito(int afiliadoId){
        ArrayList<ProductoCarritoDto> productos = new ArrayList<>();

        String query = "SELECT P.PRODUCT_ID, P.NAME, CPD.QUANTITY, (CPD.QUANTITY * P.SALE_PRICE) AS VALOR FROM CART_PRODUCT_DETAIL CPD INNER JOIN PRODUCT P ON P.PRODUCT_ID = CPD.PRODUCT_ID WHERE CPD.CART_ID = ( SELECT CART_ID FROM CART WHERE ACTIVATE = 1 AND AFFILIATE_ID = ? )";

        try(Connection conn = ConexionOracle.getConn();
            PreparedStatement pstmt = conn.prepareStatement(query)){

            pstmt.setInt(1, afiliadoId);

            try(ResultSet rs = pstmt.executeQuery()){

                while(rs.next()){
                    ProductoCarritoDto producto = new ProductoCarritoDto(
                        rs.getInt("PRODUCT_ID"),
                        rs.getString("NAME"),
                        rs.getInt("QUANTITY"),
                        rs.getDouble("VALOR")
                    );
                    productos.add(producto);
                }

            }

        } catch (SQLException e) {
            throw new RuntimeException("Error al obtener el carrito actual",e);
        }

        return productos;
    }

    public static ArrayList<ComisionDto> obtenerDatosComision(int afiliadoId){
        ArrayList<ComisionDto> comisiones = new ArrayList<>();

        String query = "SELECT  C.COMMISSION_ID, A.AFFILIATE_ID, A.FIRST_NAME, A.LAST_NAME, C.SALE_ID, C.VALOR FROM COMMISSION C INNER JOIN AFFILIATE A ON C.AFFILIATE_ID = A.AFFILIATE_ID WHERE C.AFFILIATE_ID = ?";

        try(Connection conn = ConexionOracle.getConn();
            PreparedStatement pstmt = conn.prepareStatement(query)){

            pstmt.setInt(1, afiliadoId);

            try(ResultSet rs = pstmt.executeQuery()){

                while(rs.next()){
                    ComisionDto comision = new ComisionDto(
                            rs.getInt("COMMISSION_ID"),
                            rs.getLong("AFFILIATE_ID"),
                            rs.getString("FIRST_NAME"),
                            rs.getString("LAST_NAME"),
                            rs.getInt("SALE_ID"),
                            rs.getDouble("VALOR")
                    );
                    comisiones.add(comision);
                }

            }

        } catch (SQLException e) {
            throw new RuntimeException("Error al obtener las comisiones",e);
        }

        return comisiones;
    }



    public static boolean verificarSihayCarritoActivo(int afiliadoId){

        String query = "SELECT CART_ID FROM CART WHERE ACTIVATE = 1 AND AFFILIATE_ID = ?";
        boolean salida = false;

        try(Connection conn = ConexionOracle.getConn();
            PreparedStatement pstmt = conn.prepareStatement(query)){

            pstmt.setInt(1, afiliadoId);

            try(ResultSet rs = pstmt.executeQuery()){

                if(rs.next()){
                    salida = true;
                }
            }

        } catch (SQLException e) {
            throw new RuntimeException("Error al calcular el descuento del afiliado",e);
        }

        return salida;
    }

    public static void actualizarCarrito(ObservableList<ProductoCarritoDto> CarritoNuevo, int afiliadoId) {

        vaciarCarrito(afiliadoId);
        CompraData.CargarCarrito(CarritoNuevo, afiliadoId);
    }

    public static void actualizarUnProductoCarrito(int cantidad, int afiliadoId, int productoId){
        String query = "UPDATE CART_PRODUCT_DETAIL SET QUANTITY = ? WHERE CART_ID = (SELECT CART_ID FROM CART  WHERE ACTIVATE = 1 AND AFFILIATE_ID = ?) AND PRODUCT_ID = ?";

        try (Connection conn = ConexionOracle.getConn();
             PreparedStatement pstmt = conn.prepareStatement(query)) {

                pstmt.setInt(1, cantidad);
                pstmt.setInt(2, afiliadoId);
                pstmt.setInt(3, productoId);

                int rowsAffected = pstmt.executeUpdate();

        } catch (SQLException e) {
            throw new RuntimeException("Se presento un error actualizando el registro", e);
        }
    }

    /**
     * Busca el carrito usuario del usuario y lo vacea
     * @param afiliadoId
     */
    public static void vaciarCarrito(int afiliadoId){
        String query = "DELETE FROM CART_PRODUCT_DETAIL WHERE CART_ID = (SELECT CART_ID FROM CART WHERE ACTIVATE = 1 AND AFFILIATE_ID = ?)";

        try (Connection conn = ConexionOracle.getConn();
             PreparedStatement pstmt = conn.prepareStatement(query)) {

            pstmt.setInt(1, afiliadoId);

            int rowsAffected = pstmt.executeUpdate();

        } catch (SQLException e) {
            throw new RuntimeException("Se presento un error vaciando el registro", e);
        }
    }

    public static int registrarAfiliado(Long cedula, String nombre, String apellido, String correo,
                                        String contrasena, int activate, String direccion, int level, Long parentId)  {

        int salida = 0;
        String query = "{? = CALL REGISTRAR_AFILIADO(?,?,?,?,?,?,?,?,?)}";

        try (Connection connection = ConexionOracle.getConn()) {
            try (CallableStatement cstmt = connection.prepareCall(query)) {

                //parametros de salida
                cstmt.registerOutParameter(1, java.sql.Types.INTEGER);


                cstmt.setLong(2, cedula);
                cstmt.setString(3, nombre);
                cstmt.setString(4, apellido);
                cstmt.setString(5, correo);
                cstmt.setString(6, contrasena);
                cstmt.setInt(7, activate);
                cstmt.setString(8, direccion);
                cstmt.setInt(9, level);
                cstmt.setObject(10, parentId, java.sql.Types.INTEGER); // Maneja null correctamente

                //se ejecuta la consulta
                cstmt.execute();

                // Obtener el valor del parámetro de salida
                salida = cstmt.getInt(1);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error al afiliar al usuario", e);
        }

        return salida;
    }
}
