import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/shopping_list_custom_item/entity/shopping_list_custom_item_entity.dart';
import 'package:mealapp/domain/shopping_list_custom_item/repository/shopping_list_custom_item_repository.dart';

/// ♻️ Use case — przywraca niestandardowy składnik do listy zakupów.
/// Wykorzystywany przy cofnięciu usunięcia (UNDO) w interfejsie.
class RestoreCustomItemToShoppingListUseCase
    implements UseCase<Either<Failure, void>, ShoppingListCustomItemEntity> {
  final ShoppingListCustomItemRepository repository;

  RestoreCustomItemToShoppingListUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call({ShoppingListCustomItemEntity? params}) async {
    if (params == null) {
      return Left(GeneralFailure());
    }
    return await repository.restoreCustomItemToShoppingList(params);
  }
}