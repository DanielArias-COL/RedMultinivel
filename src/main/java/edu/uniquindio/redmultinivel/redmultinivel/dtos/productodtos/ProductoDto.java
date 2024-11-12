package edu.uniquindio.redmultinivel.redmultinivel.dtos.productodtos;

import lombok.*;

@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
@ToString
public class ProductoDto {
    private int codigo;
    private String name;
    private double valor;
    private String imagePath;
    private int cantidad;


}
