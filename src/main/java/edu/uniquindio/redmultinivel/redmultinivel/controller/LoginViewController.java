package edu.uniquindio.redmultinivel.redmultinivel.controller;

import edu.uniquindio.redmultinivel.redmultinivel.App;
import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.scene.Node;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.control.Alert;
import javafx.scene.control.PasswordField;
import javafx.scene.control.TextField;
import javafx.scene.input.MouseEvent;
import javafx.scene.layout.AnchorPane;
import javafx.stage.Stage;

import java.io.IOException;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;public class LoginViewController {

    @FXML
    private TextField txtUsuario_loginView;

    @FXML
    private PasswordField txtContraseña_loginView;

    public void btnIngresar_loginView(ActionEvent actionEvent) {
        String email = txtUsuario_loginView.getText();
        String password = txtContraseña_loginView.getText();

        // Validar campos vacíos
        if (email.isEmpty() || password.isEmpty()) {
            mostrarMensaje("Error", "Campos requeridos", "Por favor ingresa el correo y la contraseña.", Alert.AlertType.ERROR);
            return;
        }

        // Conexión a la base de datos y ejecución del procedimiento
        try (Connection connection = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "felipe", "12345")) {
            String sql = "{CALL login_email_affiliate(?, ?)}";
            try (CallableStatement statement = connection.prepareCall(sql)) {
                statement.setString(1, email);
                statement.setString(2, password);

                statement.execute();

                // Si llegamos aquí sin excepción, el login fue exitoso
                mostrarMensaje("Éxito", "Inicio de sesión", "Inicio de sesión exitoso.", Alert.AlertType.INFORMATION);

                // Cargar la vista principal (main-view.fxml)
                cargarVistaPrincipal(actionEvent); // Cambié el parámetro a actionEvent
            }
        } catch (SQLException e) {
            mostrarMensaje("Error", "Error de conexión", "No se pudo conectar a la base de datos: " + e.getMessage(), Alert.AlertType.ERROR);
        }
    }

    private void mostrarMensaje(String titulo, String head, String content, Alert.AlertType tipo) {
        Alert alerta = new Alert(tipo);
        alerta.setTitle(titulo);
        alerta.setHeaderText(head);
        alerta.setContentText(content);
        alerta.show();
    }

    private App app;

    // Método para inicializar el controlador con datos iniciales
    public void initialize(App app, int i) {
        this.app = app; // Guardamos la instancia de la aplicación para futuras operaciones
        System.out.println("LoginViewController initialized with value: " + i);
    }

    // Método para manejar el evento del botón "Cancelar"
    public void btnCancelar_loginView(ActionEvent actionEvent) {
        System.out.println("Operación cancelada por el usuario.");
        // Cierra la ventana actual
        Stage stage = (Stage) ((Node) actionEvent.getSource()).getScene().getWindow();
        stage.close();
    }

    // Método para mostrar la ventana de recuperación de contraseña
    public void mostrarVentanaRecuperarContrasenia(MouseEvent mouseEvent) {
        // Comentado el código de recuperación de contraseña
    }

    // Método para mostrar la ventana de registro
    public void mostrarVentanaResgitro(MouseEvent mouseEvent) {
        try {
            FXMLLoader loader = new FXMLLoader(getClass().getResource("/edu/uniquindio/redmultinivel/redmultinivel/registroView.fxml"));
            Parent root = loader.load();

            Stage stage = (Stage) ((Node) mouseEvent.getSource()).getScene().getWindow();
            stage.setScene(new Scene(root));
            stage.setTitle("Registro de Usuario");
        } catch (IOException e) {
            e.printStackTrace();
            System.err.println("Error cargando la ventana de registro.");
        }
    }

    ///////abrir main
    public void cargarVistaPrincipal(ActionEvent actionEvent) {
        try {
            FXMLLoader loader = new FXMLLoader(getClass().getResource("/edu/uniquindio/redmultinivel/redmultinivel/main-view.fxml"));
            Parent root = loader.load();

            // Obtener el controlador del main-view (si es necesario)
            MainController mainController = loader.getController();
            mainController.initialize(new App(), 123); // Pasar información si es necesario

            // Cambiar la escena
            Stage stage = (Stage) ((Node) actionEvent.getSource()).getScene().getWindow();
            stage.setScene(new Scene(root));
            stage.setTitle("Main View");
            stage.show(); // Asegúrate de mostrar la nueva ventana
        } catch (IOException e) {
            e.printStackTrace();
            System.err.println("Error cargando la ventana principal.");
        }
    }
}
