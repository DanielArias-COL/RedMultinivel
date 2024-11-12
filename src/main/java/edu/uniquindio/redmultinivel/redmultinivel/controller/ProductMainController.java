package edu.uniquindio.redmultinivel.redmultinivel.controller;

import java.net.URL;
import java.util.ResourceBundle;

import edu.uniquindio.redmultinivel.redmultinivel.dtos.productodtos.ProductoDto;
import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.control.TextField;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.layout.AnchorPane;
import javafx.scene.layout.GridPane;


public class ProductMainController {

    private MainController mainController;
    private ProductoDto producto;
    private int cantidad;


    @FXML
    private AnchorPane anchorPanePrincipal;

    @FXML
    private GridPane GridPaneProductos;
    @FXML
    private Label labelName;

    @FXML
    private Label labelPrecio;

    @FXML
    private ImageView imageProducto;

    @FXML
    private ResourceBundle resources;

    @FXML
    private URL location;

    @FXML
    private Button buttonAgregar;

    @FXML
    private TextField textCantidad;

    @FXML
    private Button buttonDecremento;

    @FXML
    private Button buttonIncremento;

    private Image image;

    @FXML
    void incrementarCantidad(ActionEvent event) {
        int valorActual = Integer.parseInt(textCantidad.getText());
        int nuevoValor = valorActual+1;
        textCantidad.setText(""+nuevoValor);
        cantidad++;
    }

    @FXML
    void DecrementarCantidad(ActionEvent event) {
        int valorActual = Integer.parseInt(textCantidad.getText());

        if (valorActual != 0) {
            int nuevoValor = valorActual-1;
            textCantidad.setText(""+nuevoValor);
            cantidad--;
        }
    }

    @FXML
    void AgregarAlCarrito(ActionEvent event) {
        if (cantidad != 0){
            Double valorTotal = producto.getValor()*cantidad;
            mainController.agregarAlCarrito(producto.getCodigo(), producto.getName(), cantidad, valorTotal);
        }


    }

    public void init(ProductoDto productoDto, MainController mainController){

        //Ontenemos el producto para poder trabajar con el en otros métodos
        this.producto = productoDto;

        cantidad = 0;
        textCantidad.setText("0");
        this.labelName.setText(productoDto.getName());
        this.labelPrecio.setText("$ "+productoDto.getValor());
        String path = "File:"+productoDto.getImagePath();
        this.image = new Image(path,200, 137, false, true);
        this.imageProducto.setImage(image);
        this.textCantidad.setText(productoDto.getCantidad()+"");

        //Inicializamos el  controlador del main, esto para posteriormmente poder usar el método agregar
        this.mainController = mainController;
    }
}
