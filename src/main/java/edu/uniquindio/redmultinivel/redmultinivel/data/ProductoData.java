package edu.uniquindio.redmultinivel.redmultinivel.data;

import edu.uniquindio.redmultinivel.redmultinivel.dtos.productodtos.ProductoDto;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ProductoData {

    public static List<ProductoDto> obtenerProductosDTO()  {

        System.out.println(1);
        List<ProductoDto> productos = new ArrayList<>();

        Connection conn = ConexionOracle.getConn();
        PreparedStatement stmt = null;
        try {
            stmt = conn.prepareStatement("SELECT * FROM PRODUCT");

            ResultSet rslt = stmt.executeQuery();

            while (rslt.next()) {
                // Crea un nuevo objeto ProductoDto y asigna valores desde el ResultSet
                ProductoDto producto = new ProductoDto();
                producto.setCodigo(rslt.getInt("PRODUCT_ID"));
                producto.setName(rslt.getString("NAME"));
                producto.setValor(rslt.getDouble("SALE_PRICE"));
                producto.setImagePath(rslt.getString("PATH_IMAGE"));
                System.out.println(producto.toString());

                // Agrega el producto a la lista
                productos.add(producto);
            }

            conn.close();
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }


        return productos;

    }
}
