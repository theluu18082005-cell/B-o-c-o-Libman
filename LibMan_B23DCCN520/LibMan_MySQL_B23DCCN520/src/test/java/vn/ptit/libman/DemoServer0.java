package vn.ptit.libman;

import org.apache.catalina.Context;
import org.apache.catalina.startup.Tomcat;
import org.apache.catalina.webresources.DirResourceSet;
import org.apache.catalina.webresources.StandardRoot;
import vn.ptit.libman.dao.Database0;

import java.nio.file.Path;

public final class DemoServer0 {
    private DemoServer0() {}

    public static Tomcat start(int port, Path work) throws Exception {
        var tomcat = new Tomcat();
        tomcat.setBaseDir(work.toAbsolutePath().toString());
        tomcat.setPort(port);
        tomcat.getConnector().setProperty("address", "127.0.0.1");
        Context web = tomcat.addWebapp("/libman", Path.of("src/main/webapp").toAbsolutePath().toString());
        web.setParentClassLoader(DemoServer0.class.getClassLoader());
        var resources = new StandardRoot(web);
        resources.addPreResources(new DirResourceSet(resources, "/WEB-INF/classes",
            Path.of("target/classes").toAbsolutePath().toString(), "/"));
        web.setResources(resources);
        tomcat.start();
        return tomcat;
    }

    public static void main(String[] args) throws Exception {
        LocalMySqlSetup0.runIfRequested();
        if (Database0.isMySql()) {
            try (var db = Database0.open();
                 var probe = db.prepareStatement("SELECT id FROM tblMember0 WHERE 1 = 0");
                 var ignored = probe.executeQuery()) {
                System.out.println("MySQL OK: " + db.getCatalog());
            }
        }
        int port = Integer.parseInt(System.getProperty("libman.port", "8080"));
        Tomcat server = start(port, Path.of("target/tomcat"));
        System.out.println("LibMan: http://localhost:" + server.getConnector().getLocalPort() + "/libman/login");
        server.getServer().await();
    }
}
