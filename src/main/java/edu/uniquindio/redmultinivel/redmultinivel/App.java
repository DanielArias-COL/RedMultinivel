package edu.uniquindio.redmultinivel.redmultinivel;

import edu.uniquindio.redmultinivel.redmultinivel.controller.LoginViewController;
import edu.uniquindio.redmultinivel.redmultinivel.controller.MainController;
import javafx.application.Application;
import javafx.fxml.FXMLLoader;
import javafx.scene.Scene;
import javafx.scene.layout.AnchorPane;
import javafx.stage.Stage;
import lombok.Getter;

import java.io.IOException;

public class App extends Application {
    //Definimos el escenario principal
    @Getter
    Stage primaryStage;

    //Creamos un contenedor raiz para el escenario posterior
    AnchorPane contenedorRaiz;


    @Override
    public void start(Stage stage) throws Exception {

        this.primaryStage=stage;

        try {
            primaryStage.setTitle("multinivel.daniel");
            showVistaProyectos();
        } catch (IOException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
    }

    private void showVistaProyectos() throws IOException {

        //Creamos la clase FXMLLoader que nos permite cargar archivos fxml
        FXMLLoader loader = new FXMLLoader();
        //loader.setLocation(App.class.getResource("main-view.fxml"));
        loader.setLocation(App.class.getResource("loginView.fxml"));

        //Ahoraa se lee el archivo previamente cargado y se crea el arbol de nodos y se le asigna a el contenedor
        contenedorRaiz= (AnchorPane)loader.load();

        //Ahora creamos una escena y le  asignamos el contenedor
        Scene miEscenaRaiz = new Scene(contenedorRaiz);

        //Ahora setiamos nuestra escena con trodo el arbol de nodos contruido
        primaryStage.setScene(miEscenaRaiz);

        //Damos acceso al controlador a la aplicación principal.
        LoginViewController controller= loader.getController();

        //Mandamos la clase actual "this" para posteriormente poder cerrarla o esconderla para abrir nuevos escenatios
        controller.initialize(this);

        primaryStage.show();
    }

    public void cerrarVentana() {
        this.primaryStage.close();
    }

    public static void main(String[] args) {
        launch(args);

    }
}
