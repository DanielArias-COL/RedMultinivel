package edu.uniquindio.redmultinivel.redmultinivel.dtos.productodtos;

import lombok.*;

@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
@ToString
public class ProductoCarritoDto {
    Integer codigo;
    String nombreProducto;
    Integer cantidad;
    Double valor;



}
