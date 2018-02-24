class RecipesController < ApplicationController
  before_action :set_recipe, only: [:show, :edit, :update, :destroy, :like]
  before_action :require_user, except: [:index, :show, :like]
  before_action :require_same_user, only: [:edit, :update, :destroy]
  before_action :require_user_like, only: [:like]
  
  def index
    @recipes = Recipe.paginate(page: params[:page], per_page: 5)
  end
  
  def show
    @comment = Comment.new
    @comments = @recipe.comments.paginate(page: params[:page], per_page: 5)
  end
  
  def new
    @recipe = Recipe.new
  end
  
  def create
    @recipe = Recipe.new(recipe_params)
    @recipe.chef = current_chef
    if @recipe.save
      flash[:success] = "Recipe was created successfully!"
      redirect_to recipe_path(@recipe)
    else
      render 'new'
    end
  end
  
  def edit
    
  end
  
  def update
    if @recipe.update(recipe_params)
      flash[:success] = "Recipe was updated successfully!"
      redirect_to recipe_path(@recipe)
    else
      render 'edit'
    end
  end
  
  def destroy
    Recipe.find(params[:id]).destroy
    flash[:success] = "Recipe deleted successfully"
    redirect_to recipes_path
  end
  
  def like
    like = Like.find_by(chef:current_chef, recipe: @recipe)
    if like
      like_status = like.like
      if like_status.to_s == params[:like]
        flash[:success] = "You #{ if params[:like] == "true" then "unliked" else "stopped disliking" end } chef's #{current_chef.chefname} recipe #{@recipe.name}"
        like.destroy
      else
        like.like = params[:like]
        flash[:success] = "You #{ if params[:like] == "true" then "liked" else "disliked" end } chef's #{current_chef.chefname} recipe #{@recipe.name}"
        like.save
      end
      redirect_back fallback_location: root_path
    else
      like = Like.create(like: params[:like], chef: current_chef, recipe: @recipe)
      flash[:success] = "You #{ if params[:like] == "true" then "liked" else "disliked" end } chef's #{current_chef.chefname} recipe #{@recipe.name}"
      redirect_back fallback_location: root_path
    end
  end
  
  private
  
    def set_recipe
      @recipe = Recipe.find(params[:id])
    end
  
    def recipe_params
      params.require(:recipe).permit(:name, :description, ingredient_ids: [])
    end
    
    def require_same_user
      if current_chef != @recipe.chef and !current_chef.admin?
        flash[:danger] = "You can only edit or delete your own recipes"
        redirect_to recipes_path
      end  
    end
    
    def require_user_like
      if !logged_in?
        flash[:danger] = "You must be logged in to perform that action"
        redirect_back fallback_location: root_path
      end
    end
end