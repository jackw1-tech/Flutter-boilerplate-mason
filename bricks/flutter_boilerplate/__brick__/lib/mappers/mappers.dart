import 'package:{{project_name}}/model/baseModel.dart';

abstract class DTOMapper<D, M extends BaseModel> {
  D fromDTO(M dto);

  M toDTO(D model);
}
