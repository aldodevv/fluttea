import com.android.build.gradle.AppExtension

val android = project.extensions.getByType(AppExtension::class.java)

android.apply {
    flavorDimensions("flavor-type")

    productFlavors {
        create("dev") {
            dimension = "flavor-type"
            applicationId = "com.fluttea.fluttea.dev"
            resValue(type = "string", name = "app_name", value = "Fluttea Dev")
        }
        create("prod") {
            dimension = "flavor-type"
            applicationId = "com.fluttea.fluttea"
            resValue(type = "string", name = "app_name", value = "Fluttea")
        }
    }

    buildFeatures.resValues = true
}